import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NetworkInfoPage extends StatefulWidget {
  const NetworkInfoPage({super.key});

  @override
  State<NetworkInfoPage> createState() => _NetworkInfoPageState();
}

class _NetworkInfoPageState extends State<NetworkInfoPage> {
  String _connectionStatus = '检测中...';
  String _wifiIP = '获取中...';
  String _publicIP = '获取中...';
  String _wifiName = '获取中...';
  String _wifiBSSID = '获取中...';
  String _wifiGateway = '获取中...';
  String _wifiSubnet = '获取中...';
  String _adapterName = '获取中...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getNetworkInfo();
  }

  Future<void> _getNetworkInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取连接状态
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      
      String connectionType = '未连接';
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        connectionType = 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        connectionType = '移动网络';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        connectionType = '以太网';
      }

      setState(() {
        _connectionStatus = connectionType;
      });

      // 获取公网IP
      await _getPublicIP();

      // 如果连接了WiFi或以太网，获取详细信息
      if (connectivityResult.contains(ConnectivityResult.wifi) || 
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        
        final info = NetworkInfo();
        
        try {
          final wifiIP = await info.getWifiIP();
          String? wifiName;
          String? wifiBSSID;
          
          // Windows平台处理
          if (Platform.isWindows) {
            // Windows不需要位置权限即可获取网络信息
            wifiName = await info.getWifiName();
            wifiBSSID = await info.getWifiBSSID();
            // 获取Windows特有的网络适配器信息
            await _getWindowsNetworkInfo();
          } else {
            // 移动平台需要位置权限
            bool hasLocationPermission = await _requestLocationPermission();
            if (hasLocationPermission) {
              wifiName = await info.getWifiName();
              wifiBSSID = await info.getWifiBSSID();
            } else {
              wifiName = '需要位置权限';
              wifiBSSID = '需要位置权限';
            }
          }
          
          final wifiGateway = await info.getWifiGatewayIP();
          final wifiSubnet = await info.getWifiSubmask();

          setState(() {
            _wifiIP = wifiIP ?? '无法获取';
            _wifiName = wifiName?.replaceAll('"', '') ?? '无法获取';
            _wifiBSSID = wifiBSSID ?? '无法获取';
            _wifiGateway = wifiGateway ?? '无法获取';
            _wifiSubnet = wifiSubnet ?? '无法获取';
          });
        } catch (e) {
          setState(() {
            _wifiIP = '获取失败';
            _wifiName = '获取失败';
            _wifiBSSID = '获取失败';
            _wifiGateway = '获取失败';
            _wifiSubnet = '获取失败';
            if (Platform.isWindows) {
              _adapterName = '获取失败';
            }
          });
        }
      } else {
        setState(() {
          _wifiIP = '未连接网络';
          _wifiName = '未连接网络';
          _wifiBSSID = '未连接网络';
          _wifiGateway = '未连接网络';
          _wifiSubnet = '未连接网络';
          if (Platform.isWindows) {
            _adapterName = '未连接网络';
          }
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '检测失败';
        _wifiIP = '获取失败';
        _publicIP = '获取失败';
        _wifiName = '获取失败';
        _wifiBSSID = '获取失败';
        _wifiGateway = '获取失败';
        _wifiSubnet = '获取失败';
        if (Platform.isWindows) {
          _adapterName = '获取失败';
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getPublicIP() async {
    try {
      // 使用多个API服务，提高成功率
      final List<String> ipServices = [
        'https://api.ipify.org?format=json',
        'https://httpbin.org/ip',
        'https://api.myip.com',
      ];
      
      for (String service in ipServices) {
        try {
          final response = await http.get(
            Uri.parse(service),
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            String? publicIP;
            
            // 根据不同API的响应格式解析IP
            if (data['ip'] != null) {
              publicIP = data['ip'];
            } else if (data['origin'] != null) {
              publicIP = data['origin'];
            }
            
            if (publicIP != null && publicIP.isNotEmpty) {
              setState(() {
                _publicIP = publicIP!;
              });
              return;
            }
          }
        } catch (e) {
          // 继续尝试下一个服务
          continue;
        }
      }
      
      // 所有服务都失败了
      setState(() {
        _publicIP = '获取失败';
      });
    } catch (e) {
      setState(() {
        _publicIP = '获取失败';
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    // Windows平台不需要位置权限
    if (Platform.isWindows) {
      return true;
    }
    
    // 检查权限状态
    PermissionStatus status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // 请求权限
      status = await Permission.location.request();
      return status.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // 权限被永久拒绝，显示提示
      _showPermissionDialog();
      return false;
    }
    
    return false;
  }

  Future<void> _getWindowsNetworkInfo() async {
    try {
      // 使用NetworkInterface获取网络接口信息 <mcreference link="https://stackoverflow.com/questions/52411168/how-to-get-device-ip-in-dart-flutter" index="1">1</mcreference>
      final interfaces = await NetworkInterface.list();
      
      // 查找活跃的网络接口
      for (final interface in interfaces) {
        if (interface.addresses.isNotEmpty) {
          // 查找IPv4地址
          for (final address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4 && 
                !address.isLoopback && 
                address.address != '169.254.0.0') {
              setState(() {
                _adapterName = interface.name;
              });
              return;
            }
          }
        }
      }
      
      setState(() {
        _adapterName = '无活跃适配器';
      });
    } catch (e) {
      setState(() {
        _adapterName = '获取失败';
      });
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '需要位置权限',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('获取WiFi名称需要位置权限，请在设置中开启位置权限。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    if (text != '获取中...' && text != '无法获取' && text != '获取失败' && 
        text != '未连接WiFi' && text != '未连接网络') {
      Clipboard.setData(ClipboardData(text: text));
      Get.snackbar(
        '已复制',
        '$label 已复制到剪贴板',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '网络信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _getNetworkInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  
                  // 连接状态卡片
                  _buildInfoCard(
                    '连接状态',
                    [
                      _buildInfoItem(
                        icon: Icons.wifi,
                        title: '网络类型',
                        value: _connectionStatus,
                        onTap: null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 网络信息卡片
                  _buildInfoCard(
                    Platform.isWindows ? '网络信息' : 'WiFi 信息',
                    [
                      _buildInfoItem(
                        icon: Platform.isWindows ? Icons.network_wifi : Icons.wifi_outlined,
                        title: Platform.isWindows ? '网络名称' : 'WiFi名称',
                        value: _wifiName,
                        onTap: () => _copyToClipboard(_wifiName, Platform.isWindows ? '网络名称' : 'WiFi名称'),
                      ),
                      if (Platform.isWindows)
                        _buildInfoItem(
                          icon: Icons.settings_ethernet,
                          title: '适配器名称',
                          value: _adapterName,
                          onTap: () => _copyToClipboard(_adapterName, '适配器名称'),
                        ),
                      _buildInfoItem(
                        icon: Icons.router_outlined,
                        title: 'BSSID',
                        value: _wifiBSSID,
                        onTap: () => _copyToClipboard(_wifiBSSID, 'BSSID'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // IP信息卡片
                  _buildInfoCard(
                    'IP 信息',
                    [
                      _buildInfoItem(
                        icon: Icons.public_outlined,
                        title: '公网IP',
                        value: _publicIP,
                        onTap: () => _copyToClipboard(_publicIP, '公网IP'),
                      ),
                      _buildInfoItem(
                        icon: Icons.computer_outlined,
                        title: '局域网IP',
                        value: _wifiIP,
                        onTap: () => _copyToClipboard(_wifiIP, '局域网IP'),
                      ),
                      _buildInfoItem(
                        icon: Icons.router,
                        title: '网关IP',
                        value: _wifiGateway,
                        onTap: () => _copyToClipboard(_wifiGateway, '网关IP'),
                      ),
                      _buildInfoItem(
                        icon: Icons.network_check_outlined,
                        title: '子网掩码',
                        value: _wifiSubnet,
                        onTap: () => _copyToClipboard(_wifiSubnet, '子网掩码'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final bool canCopy = onTap != null && 
        value != '获取中...' && 
        value != '无法获取' && 
        value != '获取失败' && 
        value != '未连接WiFi' && 
        value != '未连接网络';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF007AFF),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: canCopy ? const Color(0xFF007AFF) : Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (canCopy)
              const Icon(
                Icons.copy,
                color: Colors.grey,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
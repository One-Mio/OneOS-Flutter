import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import '../controllers/auth_controller.dart';
import '../controllers/account_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/account_book_controller.dart';
import '../models/app_model.dart';
import './working_hours/working_hours_page.dart';
import './settings/settings_page.dart';
import './payroll/pay_stub_page.dart';
import './qr_code/qr_code_page.dart';
import './other/phone_page.dart';
import './other/bank_card_page.dart';
import './accounting/finance_main_page.dart';
import './games/fast_three_game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // 模拟应用数据
  List<AppModel> get _apps => [
    AppModel(
      name: '工时记录',
      icon: Icons.timer,
      color: Colors.grey,
      onTap: () => Get.to(() => const WorkingHoursPage()),
    ),
    AppModel(
      name: '设置',
      icon: Icons.settings,
      color: Colors.grey.shade600,
      onTap: () => Get.to(() => const SettingsPage()),
    ),
    AppModel(
      name: '薪资单',
      icon: Icons.receipt_long,
      color: Colors.purple,
      onTap: () => Get.to(() => const PayStubPage()),
    ),
    AppModel(
      name: '二维码',
      icon: Icons.qr_code,
      color: Colors.orange,
      onTap: () => Get.to(() => const QrCodePage()),
    ),
    AppModel(
      name: '记账',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
      onTap: () => Get.to(() => const FinanceMainPage()),
    ),
    AppModel(
      name: '银行卡',
      icon: Icons.credit_card,
      color: Colors.teal,
      onTap: () => Get.to(() => const BankCardPage()),
    ),
    AppModel(
      name: '快三',
      icon: Icons.casino,
      color: Colors.red,
      onTap: () => Get.to(() => const FastThreeGamePage()),
    ),
  ];

  // 根据屏幕宽度计算网格列数
  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) {
      return 8; // 大屏幕显示8列
    } else if (screenWidth > 800) {
      return 6; // 中等屏幕显示6列
    } else if (screenWidth > 600) {
      return 5; // 平板显示5列
    } else {
      return 4; // 手机显示4列
    }
  }

  // 根据屏幕尺寸调整间距
  double _calculateSpacing(double screenWidth) {
    if (screenWidth > 1200) {
      return 24.0;
    } else if (screenWidth > 800) {
      return 20.0;
    } else {
      return 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 800;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Windows风格的渐变背景
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0078D4), // Windows蓝
              const Color(0xFF106EBE),
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Column(
          children: [
            // 顶部标题栏（Windows风格）
            if (isLargeScreen)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.computer,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'OneOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Windows风格的控制按钮
                    Row(
                      children: [
                        _buildWindowsButton(Icons.minimize, () {}),
                        _buildWindowsButton(Icons.crop_square, () {}),
                        _buildWindowsButton(Icons.close, () {}),
                      ],
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 16),
            
            // 应用网格
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 32.0 : 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
                    final spacing = _calculateSpacing(constraints.maxWidth);
                    
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: isLargeScreen ? 1.1 : 1.0,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: _apps.length,
                      itemBuilder: (context, index) {
                        final app = _apps[index];
                        return _buildAppIcon(app, isLargeScreen);
                      },
                    );
                  },
                ),
              ),
            ),
            
            // 底部任务栏（Windows风格）
            Container(
              height: isLargeScreen ? 60 : 80,
              margin: EdgeInsets.all(isLargeScreen ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDockIcon(Icons.phone, '电话', Colors.green, isLargeScreen, onTap: () => Get.to(() => const PhonePage())),
                  _buildDockIcon(Icons.message, '短信', Colors.blue, isLargeScreen),
                  _buildDockIcon(Icons.web, '浏览器', Colors.orange, isLargeScreen),
                  _buildDockIcon(Icons.camera_alt, '相机', Colors.red, isLargeScreen),
                  if (isLargeScreen) ...[
                    _buildDockIcon(Icons.folder, '文件', Colors.yellow.shade700, isLargeScreen),
                    _buildDockIcon(Icons.settings, '设置', Colors.grey, isLargeScreen, onTap: () => Get.to(() => const SettingsPage())),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建Windows风格的控制按钮
  Widget _buildWindowsButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  // 构建应用图标
  Widget _buildAppIcon(AppModel app, bool isLargeScreen) {
    return InkWell(
      onTap: app.onTap,
      onSecondaryTap: isLargeScreen ? () => _showContextMenu(app) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: FittedBox(
                  child: Icon(
                    app.icon,
                    size: isLargeScreen ? 48 : 40,
                    color: app.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 1,
              child: Text(
                app.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isLargeScreen ? 14 : 13,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示右键菜单
  void _showContextMenu(AppModel app) {
    // 这里可以添加右键菜单功能
    Get.snackbar(
      '右键菜单',
      '${app.name} - 右键菜单功能',
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // 构建Dock图标
  Widget _buildDockIcon(IconData icon, String label, Color color, bool isLargeScreen, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => Get.snackbar('提示', '点击了$label'),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 12 : 8,
          vertical: isLargeScreen ? 8 : 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLargeScreen ? 6 : 8),
          color: Colors.white.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isLargeScreen ? 24 : 30,
            ),
            if (!isLargeScreen) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
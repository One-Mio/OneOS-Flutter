import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/pocketbase_service.dart';
import 'network_info_page.dart';
import '../other/device_info_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final PocketBaseService pocketBaseService = Get.find<PocketBaseService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            _buildUserCard(authController, pocketBaseService),
            const SizedBox(height: 16),
            
            // 设备信息
            _buildSettingsCard(
              title: '设备信息',
              items: [
                _buildSettingsItem(
                  icon: Icons.phone_android,
                  title: '我的设备',
                  subtitle: '查看设备详细信息',
                  onTap: () => Get.to(() => const DeviceInfoPage()),
                ),
                _buildSettingsItem(
                  icon: Icons.network_wifi,
                  title: '网络信息',
                  subtitle: '查看网络IP、局域网IP',
                  onTap: () => Get.to(() => NetworkInfoPage()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 系统设置
            _buildSettingsCard(
              title: '系统设置',
              items: [
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: '通知管理',
                  subtitle: '消息通知、提醒设置',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.security,
                  title: '隐私与安全',
                  subtitle: '权限管理、数据保护',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.palette_outlined,
                  title: '显示与主题',
                  subtitle: '主题、字体大小',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.storage,
                  title: '存储管理',
                  subtitle: '清理缓存、管理存储',
                  onTap: () => _showComingSoon(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 应用设置
            _buildSettingsCard(
              title: '应用设置',
              items: [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: '语言与地区',
                  subtitle: '中文（简体）',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.update,
                  title: '检查更新',
                  subtitle: '当前版本 1.0.0',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.backup,
                  title: '备份与恢复',
                  subtitle: '数据备份与同步',
                  onTap: () => _showComingSoon(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 其他
            _buildSettingsCard(
              title: '其他',
              items: [
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  subtitle: '使用帮助、问题反馈',
                  onTap: () => _showComingSoon(),
                ),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  title: '关于应用',
                  subtitle: '版本信息与开发者',
                  onTap: () => _showAbout(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 退出登录按钮
            Obx(() => authController.isLoggedIn
                ? _buildLogoutButton(authController)
                : const SizedBox()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AuthController authController, PocketBaseService pocketBaseService) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Obx(() => authController.isLoggedIn
          ? _buildLoggedInUser(pocketBaseService)
          : _buildLoginPrompt(authController)),
    );
  }

  Widget _buildLoggedInUser(PocketBaseService pocketBaseService) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pocketBaseService.pb.authStore.model?.data['email'] ?? '用户',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '已登录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(AuthController authController) {
    return InkWell(
      onTap: () => authController.showLoginPage(),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey.shade600,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '登录账号',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '登录后可同步数据',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> items}) {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(authController),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showComingSoon() {
    Get.snackbar(
      '提示',
      '功能开发中，敬请期待',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '关于 OneOS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text('应用版本: 1.0.0'),
            SizedBox(height: 8),
            Text('Flutter版本: 3.35.1'),
            SizedBox(height: 8),
            Text('Dart版本: 3.9.0'),
            SizedBox(height: 16),
            Text(
              '基于Flutter开发的现代化移动应用',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '确定',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '确定要退出登录吗？退出后需要重新登录才能同步数据。',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
              Get.snackbar(
                '提示',
                '已成功退出登录',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
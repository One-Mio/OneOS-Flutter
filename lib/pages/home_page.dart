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
import './endowment_insurance/endowment_insurance_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // iOS风格应用数据
  List<AppModel> get _apps => [
    AppModel(
      name: '工时记录',
      icon: Icons.timer,
      color: const Color(0xFF007AFF),
      onTap: () => Get.to(() => const WorkingHoursPage()),
    ),
    AppModel(
      name: '设置',
      icon: Icons.settings,
      color: const Color(0xFF8E8E93),
      onTap: () => Get.to(() => const SettingsPage()),
    ),
    AppModel(
      name: '薪资单',
      icon: Icons.receipt_long,
      color: const Color(0xFFAF52DE),
      onTap: () => Get.to(() => const PayStubPage()),
    ),
    AppModel(
      name: '二维码',
      icon: Icons.qr_code,
      color: const Color(0xFFFF9500),
      onTap: () => Get.to(() => const QrCodePage()),
    ),
    AppModel(
      name: '记账',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF34C759),
      onTap: () => Get.to(() => const FinanceMainPage()),
    ),
    AppModel(
      name: '电话',
      icon: Icons.phone,
      color: const Color(0xFF30D158),
      onTap: () => Get.to(() => const PhonePage()),
    ),
    AppModel(
      name: '银行卡',
      icon: Icons.credit_card,
      color: const Color(0xFF007AFF),
      onTap: () => Get.to(() => const BankCardPage()),
    ),
    AppModel(
      name: '快三游戏',
      icon: Icons.casino,
      color: const Color(0xFFFF3B30),
      onTap: () => Get.to(() => const FastThreeGamePage()),
    ),
    AppModel(
      name: '养老保险',
      icon: Icons.account_balance,
      color: const Color(0xFF32D74B),
      onTap: () => Get.to(() => const EndowmentInsurancePage()),
    ),
  ];

  // Dock栏应用
  List<AppModel> get _dockApps => [
    AppModel(
      name: '电话',
      icon: Icons.phone,
      color: const Color(0xFF30D158),
      onTap: () => Get.to(() => const PhonePage()),
    ),
    AppModel(
      name: '记账',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF34C759),
      onTap: () => Get.to(() => const FinanceMainPage()),
    ),
    AppModel(
      name: '设置',
      icon: Icons.settings,
      color: const Color(0xFF8E8E93),
      onTap: () => Get.to(() => const SettingsPage()),
    ),
    AppModel(
      name: '工时记录',
      icon: Icons.timer,
      color: const Color(0xFF007AFF),
      onTap: () => Get.to(() => const WorkingHoursPage()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/phone _wallpapers.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 主要应用网格区域
              Expanded(
                child: _buildAppGrid(isLargeScreen),
              ),
              
              // 底部Dock栏
              _buildDock(isLargeScreen),
            ],
          ),
        ),
      ),
    );
  }

  // 构建应用网格
  Widget _buildAppGrid(bool isLargeScreen) {
    final crossAxisCount = isLargeScreen ? 5 : 4;
    final mainApps = _apps.take(crossAxisCount * 4).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: mainApps.length,
        itemBuilder: (context, index) {
          return _buildAppIcon(mainApps[index], isLargeScreen);
        },
      ),
    );
  }

  // 构建应用图标
  Widget _buildAppIcon(AppModel app, bool isLargeScreen) {
    return GestureDetector(
      onTap: app.onTap,
      onLongPress: () => _showAppMenu(app),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标容器
          Container(
            width: isLargeScreen ? 70 : 60,
            height: isLargeScreen ? 70 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  app.color.withOpacity(0.9),
                  app.color,
                  app.color.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: app.color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              app.icon,
              size: isLargeScreen ? 32 : 28,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 应用名称
          Expanded(
            child: Text(
              app.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 12 : 11,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 构建Dock栏
  Widget _buildDock(bool isLargeScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _dockApps.map((app) => _buildDockIcon(app, isLargeScreen)).toList(),
      ),
    );
  }

  // 构建Dock图标
  Widget _buildDockIcon(AppModel app, bool isLargeScreen) {
    return GestureDetector(
      onTap: app.onTap,
      onLongPress: () => _showAppMenu(app),
      child: Container(
        width: isLargeScreen ? 64 : 56,
        height: isLargeScreen ? 64 : 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLargeScreen ? 14 : 12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              app.color.withOpacity(0.9),
              app.color,
              app.color.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          app.icon,
          size: isLargeScreen ? 28 : 24,
          color: Colors.white,
        ),
      ),
    );
  }

  // 显示应用菜单
  void _showAppMenu(AppModel app) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        app.color.withOpacity(0.9),
                        app.color,
                        app.color.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Icon(
                    app.icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '应用详情',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuButton(
                  icon: Icons.share,
                  label: '分享',
                  onTap: () {
                    Get.back();
                    Get.snackbar('分享', '${app.name} - 分享功能');
                  },
                ),
                _buildMenuButton(
                  icon: Icons.edit,
                  label: '编辑',
                  onTap: () {
                    Get.back();
                    Get.snackbar('编辑', '${app.name} - 编辑功能');
                  },
                ),
                _buildMenuButton(
                  icon: Icons.delete_outline,
                  label: '删除',
                  onTap: () {
                    Get.back();
                    Get.snackbar('删除', '${app.name} - 删除功能');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 构建菜单按钮
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
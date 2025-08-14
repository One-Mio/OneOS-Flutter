import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/app_model.dart';
import './working_hours_page.dart';
import './settings_page.dart';

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
      name: '相机',
      icon: Icons.camera_alt,
      color: Colors.purple,
      onTap: () => Get.snackbar('提示', '点击了相机应用'),
    ),
    AppModel(
      name: '时钟',
      icon: Icons.access_time,
      color: Colors.orange,
      onTap: () => Get.snackbar('提示', '点击了时钟应用'),
    ),
    AppModel(
      name: '地图',
      icon: Icons.map,
      color: Colors.green,
      onTap: () => Get.snackbar('提示', '点击了地图应用'),
    ),
    AppModel(
      name: '天气',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      onTap: () => Get.snackbar('提示', '点击了天气应用'),
    ),
    AppModel(
      name: '计算器',
      icon: Icons.calculate,
      color: Colors.blue,
      onTap: () => Get.snackbar('提示', '点击了计算器应用'),
    ),
    AppModel(
      name: '音乐',
      icon: Icons.music_note,
      color: Colors.red,
      onTap: () => Get.snackbar('提示', '点击了音乐应用'),
    ),
    AppModel(
      name: '管理',
      icon: Icons.admin_panel_settings,
      color: Colors.teal,
      onTap: () {
        final AuthController authController = Get.find<AuthController>();
        if (authController.isLoggedIn) {
          Get.snackbar('提示', '您已登录，可以访问管理功能');
        } else {
          authController.showLoginPage();
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // 添加渐变背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.purple.shade200,
            ],
          ),
        ),
        child: Column(
          children: [
            // 顶部状态区域 - 空白区域
            const SizedBox(height: 16),
            
            // 应用网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _apps.length,
                  itemBuilder: (context, index) {
                    final app = _apps[index];
                    return _buildAppIcon(app);
                  },
                ),
              ),
            ),
            
            // 底部固定区域（模拟Dock）
            Container(
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDockIcon(Icons.phone, '电话', Colors.green),
                  _buildDockIcon(Icons.message, '短信', Colors.blue),
                  _buildDockIcon(Icons.web, '浏览器', Colors.orange),
                  _buildDockIcon(Icons.camera_alt, '相机', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建应用图标
  Widget _buildAppIcon(AppModel app) {
    return InkWell(
      onTap: app.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FittedBox(
                child: Icon(
                  app.icon,
                  size: 40,
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建Dock图标
  Widget _buildDockIcon(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => Get.snackbar('提示', '点击了$label'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
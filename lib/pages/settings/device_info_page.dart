import 'package:flutter/material.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备信息'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('设备型号'),
                subtitle: Text('获取中...'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('系统版本'),
                subtitle: Text('获取中...'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.apps),
                title: Text('应用版本'),
                subtitle: Text('1.0.0'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
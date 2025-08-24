import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _qrData = 'Hello World';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _textController.text = _qrData;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _qrData = _textController.text;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      Get.snackbar(
        '提示',
        '请输入要生成二维码的内容',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
     );
    }
  }

  Widget _buildInputSection(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: '输入要生成二维码的内容',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isLargeScreen ? 16 : 14,
          ),
          hintText: '请输入文本、网址、联系方式等内容',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: isLargeScreen ? 14 : 12,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isLargeScreen ? 20 : 16),
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.blue.shade400,
            size: isLargeScreen ? 24 : 20,
          ),
        ),
        maxLines: isLargeScreen ? 4 : 3,
        style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
      ),
    );
  }

  Widget _buildGenerateButton(bool isLargeScreen) {
    return Container(
      height: isLargeScreen ? 64 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: isLargeScreen ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _generateQrCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              color: Colors.white,
              size: isLargeScreen ? 28 : 24,
            ),
            SizedBox(width: isLargeScreen ? 12 : 8),
            Text(
              '生成二维码',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeDisplay(bool isLargeScreen) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isLargeScreen ? 32 : 24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: isLargeScreen ? 24 : 20,
                    spreadRadius: isLargeScreen ? 3 : 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 32 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isLargeScreen ? 28 : 20),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: isLargeScreen ? 300.0 : 220.0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 24 : 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.link,
            label: '网址链接',
            onTap: () => _textController.text = 'https://',
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.wifi,
            label: 'WiFi信息',
            onTap: () => _textController.text = 'WIFI:T:WPA;S:网络名称;P:密码;;',
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.contact_page,
            label: '联系方式',
            onTap: () => _textController.text = 'BEGIN:VCARD\nVERSION:3.0\nFN:姓名\nTEL:电话号码\nEND:VCARD',
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.clear,
            label: '清空内容',
            onTap: () => _textController.clear(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLargeScreen
                ? [Colors.blue.shade600, Colors.blue.shade700, Colors.indigo.shade600]
                : [Colors.blue.shade400, Colors.purple.shade300, Colors.pink.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义AppBar
              _buildAppBar(isLargeScreen),
              
              // 主要内容区域
              Expanded(
                child: isLargeScreen 
                    ? _buildLargeScreenLayout()
                    : _buildMobileLayout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: isLargeScreen ? 24 : 20,
            ),
          ),
          Expanded(
            child: Text(
              '二维码生成器',
              style: TextStyle(
                color: Colors.white,
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: isLargeScreen ? 52 : 48), // 平衡布局
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(false),
            const SizedBox(height: 20),
            _buildGenerateButton(false),
            const SizedBox(height: 32),
            Expanded(
              child: _buildQrCodeDisplay(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧输入和控制区域
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '输入内容',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputSection(true),
                  const SizedBox(height: 24),
                  _buildGenerateButton(true),
                  const SizedBox(height: 32),
                  _buildQuickActions(),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // 右侧二维码显示区域
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '生成的二维码',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildQrCodeDisplay(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
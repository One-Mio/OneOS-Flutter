import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  String _dialNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '电话',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildDialPad(),
    );
  }

  // 构建拨号键盘
  Widget _buildDialPad() {
    return Column(
      children: [
        // 号码显示区域
        Container(
          height: 100,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    _dialNumber.isEmpty ? '输入号码' : _dialNumber,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _dialNumber.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              // 删除按钮
              if (_dialNumber.isNotEmpty)
                IconButton(
                  onPressed: () {
                    // 添加震动反馈
                    HapticFeedback.lightImpact();
                    setState(() {
                      _dialNumber = _dialNumber.substring(0, _dialNumber.length - 1);
                    });
                  },
                  icon: const Icon(Icons.backspace, size: 28),
                  color: Colors.grey,
                ),
            ],
          ),
        ),
        
        // 拨号键盘
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildDialButton('1', ''),
                _buildDialButton('2', 'ABC'),
                _buildDialButton('3', 'DEF'),
                _buildDialButton('4', 'GHI'),
                _buildDialButton('5', 'JKL'),
                _buildDialButton('6', 'MNO'),
                _buildDialButton('7', 'PQRS'),
                _buildDialButton('8', 'TUV'),
                _buildDialButton('9', 'WXYZ'),
                _buildDialButton('*', ''),
                _buildDialButton('0', '+'),
                _buildDialButton('#', ''),
              ],
            ),
          ),
        ),
        
        // 拨打电话按钮区域
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _dialNumber.isNotEmpty ? () {
                  // 添加震动反馈
                  HapticFeedback.mediumImpact();
                  _makeCall(_dialNumber);
                } : null,
                icon: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建拨号按钮
  Widget _buildDialButton(String number, String letters) {
    return InkWell(
      onTap: () {
        // 添加震动反馈
        HapticFeedback.lightImpact();
        setState(() {
          _dialNumber += number;
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }



  // 拨打电话
  void _makeCall(String number) {
    Get.snackbar(
      '拨打电话',
      '正在拨打 $number',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }



}
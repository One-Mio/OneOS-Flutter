import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  String _generatedPassword = '';
  double _passwordLength = 15;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;

  final String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  final String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _numberChars = '0123456789';
  final String _specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    if (!_includeLowercase && !_includeUppercase && !_includeNumbers && !_includeSpecialChars) {
      setState(() {
        _generatedPassword = '请至少选择一种字符类型';
      });
      return;
    }

    String availableChars = '';
    if (_includeLowercase) availableChars += _lowercaseChars;
    if (_includeUppercase) availableChars += _uppercaseChars;
    if (_includeNumbers) availableChars += _numberChars;
    if (_includeSpecialChars) availableChars += _specialChars;

    final random = Random();
    String password = '';
    
    for (int i = 0; i < _passwordLength.toInt(); i++) {
      password += availableChars[random.nextInt(availableChars.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty && _generatedPassword != '请至少选择一种字符类型') {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      Get.snackbar(
        '复制成功',
        '密码已复制到剪贴板',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '随机密码生成器',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFFA855F7),
              Color(0xFFEC4899),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 生成的密码显示区域
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '生成的密码',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: SelectableText(
                          _generatedPassword,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generatePassword,
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text(
                                '重新生成',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy, color: Colors.white),
                              label: const Text(
                                '复制',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 设置区域
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '密码设置',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // 密码长度设置
                        Text(
                          '密码长度: ${_passwordLength.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF7C3AED),
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                            thumbColor: const Color(0xFF7C3AED),
                            overlayColor: const Color(0xFF7C3AED).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _passwordLength,
                            min: 5,
                            max: 20,
                            divisions: 15,
                            onChanged: (value) {
                              setState(() {
                                _passwordLength = value;
                              });
                              _generatePassword();
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 字符类型选择
                        const Text(
                          '包含字符类型',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildCheckboxTile(
                          title: '小写字母 (a-z)',
                          value: _includeLowercase,
                          onChanged: (value) {
                            setState(() {
                              _includeLowercase = value!;
                            });
                            _generatePassword();
                          },
                        ),
                        
                        _buildCheckboxTile(
                          title: '大写字母 (A-Z)',
                          value: _includeUppercase,
                          onChanged: (value) {
                            setState(() {
                              _includeUppercase = value!;
                            });
                            _generatePassword();
                          },
                        ),
                        
                        _buildCheckboxTile(
                          title: '数字 (0-9)',
                          value: _includeNumbers,
                          onChanged: (value) {
                            setState(() {
                              _includeNumbers = value!;
                            });
                            _generatePassword();
                          },
                        ),
                        
                        _buildCheckboxTile(
                          title: '特殊字符 (!@#\$%^&*)',
                          value: _includeSpecialChars,
                          onChanged: (value) {
                            setState(() {
                              _includeSpecialChars = value!;
                            });
                            _generatePassword();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3AED),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
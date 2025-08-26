import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankCardPage extends StatelessWidget {
  const BankCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '银行卡',
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
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showAddCardDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '我的银行卡',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // 银行卡列表
            _buildRealisticBankCard(
              bankName: 'INDUSTRIAL AND COMMERCIAL BANK OF CHINA',
              bankNameCN: '中国工商银行',
              cardNumber: '6222 0202 0000 1234',
              holderName: 'ZHANG SAN',
              validThru: '12/28',
              cardType: 'DEBIT',
              cardColor: const LinearGradient(
                colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              logoColor: Colors.white,
              balance: '¥12,345.67',
              accountType: '一类卡',
              branchName: '北京分行',
            ),
            const SizedBox(height: 16),
            
            _buildRealisticBankCard(
              bankName: 'CHINA CONSTRUCTION BANK',
              bankNameCN: '中国建设银行',
              cardNumber: '4367 4200 0000 5678',
              holderName: 'LI SI',
              validThru: '09/27',
              cardType: 'CREDIT',
              cardColor: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              logoColor: Colors.white,
              balance: '¥8,999.00',
              accountType: '二类卡',
              branchName: '上海浦东支行',
            ),
            const SizedBox(height: 16),
            
            _buildRealisticBankCard(
              bankName: 'AGRICULTURAL BANK OF CHINA',
              bankNameCN: '中国农业银行',
              cardNumber: '6228 4800 1234 5678',
              holderName: 'ZHAO LIU',
              validThru: '03/26',
              cardType: 'DEBIT',
              cardColor: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              logoColor: Colors.white,
              balance: '¥3,456.12',
              accountType: '二类卡',
              branchName: '广州天河支行',
            ),
            const SizedBox(height: 16),
            
            _buildRealisticBankCard(
              bankName: 'BANK OF CHINA',
              bankNameCN: '中国银行',
              cardNumber: '4563 9601 0000 3456',
              holderName: 'ZHAO LIU',
              validThru: '03/26',
              cardType: 'CREDIT',
              cardColor: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              logoColor: Colors.white,
              balance: '¥67,890.45',
              accountType: '一类卡',
              branchName: '杭州西湖支行',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealisticBankCard({
    required String bankName,
    required String bankNameCN,
    required String cardNumber,
    required String holderName,
    required String validThru,
    required String cardType,
    required LinearGradient cardColor,
    required Color logoColor,
    String? balance,
    String? accountType, // 一类卡/二类卡
    String? branchName, // 开户网点
  }) {
    return AspectRatio(
      aspectRatio: 1.586, // 标准银行卡比例
      child: Container(
        width: double.infinity,
      decoration: BoxDecoration(
        gradient: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景纹理效果
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：银行名称和银联标志
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bankNameCN,
                            style: TextStyle(
                              color: logoColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            bankName,
                            style: TextStyle(
                              color: logoColor.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 银行Logo
                    Flexible(
                      child: _buildBankLogo(bankName),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 卡号
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    cardNumber,
                    style: TextStyle(
                      color: logoColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const Spacer(),
                
                // 余额信息
                if (balance != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '余额',
                          style: TextStyle(
                            color: logoColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          balance,
                          style: TextStyle(
                            color: logoColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 底部信息行
                Row(
                  children: [
                    // 左侧：持卡人和卡类型
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holderName,
                            style: TextStyle(
                              color: logoColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (accountType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                accountType,
                                style: TextStyle(
                                  color: logoColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // 右侧：有效期和开户网点
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            validThru,
                            style: TextStyle(
                              color: logoColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (branchName != null)
                            Text(
                              branchName,
                              style: TextStyle(
                                color: logoColor.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          

        ],
      ),
      ),
    );
  }

  Widget _buildBankLogo(String bankName) {
    // 根据银行名称返回相应的logo
    switch (bankName.toLowerCase()) {
      case 'icbc':
      case '工商银行':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'ICBC',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'ccb':
      case '建设银行':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'CCB',
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'abc':
      case '农业银行':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'ABC',
            style: TextStyle(
              color: Color(0xFF388E3C),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'boc':
      case '中国银行':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'BOC',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '银联',
            style: TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  void _showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加银行卡'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '银行名称',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '卡号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '余额',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.snackbar(
                  '提示',
                  '银行卡添加功能开发中...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}
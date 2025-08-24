import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';
import 'bet_records_page.dart';

// 游戏记录模型（用于内部游戏逻辑）
class GameRecord {
  final DateTime time;
  final String betType;
  final List<int> selectedNumbers;
  final int betAmount;
  final List<int> resultNumbers;
  final int resultSum;
  final bool isWin;
  final int winAmount;
  final String result;
  
  GameRecord({
    required this.time,
    required this.betType,
    required this.selectedNumbers,
    required this.betAmount,
    required this.resultNumbers,
    required this.resultSum,
    required this.isWin,
    required this.winAmount,
    required this.result,
  });
}

class FastThreeGamePage extends StatefulWidget {
  const FastThreeGamePage({super.key});

  @override
  State<FastThreeGamePage> createState() => _FastThreeGamePageState();
}

class _FastThreeGamePageState extends State<FastThreeGamePage> {
  // 游戏状态
  List<int> currentNumbers = [1, 1, 1];
  List<int> selectedNumbers = [];
  int betAmount = 10;
  int balance = 1000;
  bool isRolling = false;
  String gameResult = '';
  final TextEditingController _customAmountController = TextEditingController();
  
  // 下注记录
  List<GameRecord> betRecords = [];
  
  // 投注类型
  String selectedBetType = '大小';
  final List<String> betTypes = ['大小', '单双', '豹子', '顺子', '对子'];
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }
  
  // 投注并摇骰子
  void placeBetAndRoll() {
    if (isRolling || selectedNumbers.isEmpty) return;
    
    setState(() {
      isRolling = true;
      gameResult = '';
    });
    
    // 模拟摇骰子动画
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timer.tick >= 20) {
        timer.cancel();
        setState(() {
          isRolling = false;
          checkResult();
        });
      } else {
        setState(() {
          currentNumbers = [
            Random().nextInt(6) + 1,
            Random().nextInt(6) + 1,
            Random().nextInt(6) + 1,
          ];
        });
      }
    });
  }
  
  // 检查结果
  void checkResult() {
    int sum = currentNumbers.reduce((a, b) => a + b);
    bool isWin = false;
    int winAmount = 0;
    
    switch (selectedBetType) {
      case '大小':
        if (selectedNumbers.isNotEmpty) {
          bool isBig = sum >= 11;
          bool selectedBig = selectedNumbers[0] == 1; // 1代表大，0代表小
          isWin = isBig == selectedBig;
          winAmount = isWin ? betAmount * 2 : 0;
        }
        break;
      case '单双':
        if (selectedNumbers.isNotEmpty) {
          bool isOdd = sum % 2 == 1;
          bool selectedOdd = selectedNumbers[0] == 1; // 1代表单，0代表双
          isWin = isOdd == selectedOdd;
          winAmount = isWin ? betAmount * 2 : 0;
        }
        break;
      case '豹子':
        bool isLeopard = currentNumbers[0] == currentNumbers[1] && 
                        currentNumbers[1] == currentNumbers[2];
        isWin = isLeopard;
        winAmount = isWin ? betAmount * 50 : 0;
        break;
      case '顺子':
        List<int> sorted = [...currentNumbers]..sort();
        bool isStraight = (sorted[0] + 1 == sorted[1]) && (sorted[1] + 1 == sorted[2]);
        isWin = isStraight;
        winAmount = isWin ? betAmount * 10 : 0;
        break;
      case '对子':
        bool isPair = currentNumbers[0] == currentNumbers[1] ||
                     currentNumbers[1] == currentNumbers[2] ||
                     currentNumbers[0] == currentNumbers[2];
        isWin = isPair;
        winAmount = isWin ? betAmount * 5 : 0;
        break;
    }
    
    setState(() {
      if (selectedNumbers.isNotEmpty) {
        // 添加下注记录
        betRecords.insert(0, GameRecord(
          time: DateTime.now(),
          betType: selectedBetType,
          selectedNumbers: [...selectedNumbers],
          betAmount: betAmount,
          resultNumbers: [...currentNumbers],
          resultSum: sum,
          isWin: isWin,
          winAmount: winAmount,
          result: isWin ? '中奖 +$winAmount' : '未中奖 -$betAmount',
        ));
        
        if (isWin) {
          balance += winAmount;
          gameResult = '恭喜中奖！赢得 $winAmount 金币';
        } else {
          balance -= betAmount;
          gameResult = '很遗憾，没有中奖';
        }
      } else {
        gameResult = '点数：$sum';
      }
      selectedNumbers.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快三'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade400, Colors.red.shade800],
          ),
        ),
        child: Column(
          children: [
            // 游戏信息栏
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '余额: $balance',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedNumbers.isNotEmpty && !isRolling ? placeBetAndRoll : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.red,
                    ),
                    child: Text(isRolling ? '摇奖中...' : '立即投注'),
                  ),
                ],
              ),
            ),
            
            // 骰子显示区域
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: currentNumbers.map((number) => _buildDice(number)).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '总和: ${currentNumbers.reduce((a, b) => a + b)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (gameResult.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        gameResult,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gameResult.contains('恭喜') ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 投注区域
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // 投注类型选择
                    Row(
                      children: [
                        const Text(
                          '投注类型: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedBetType,
                            items: betTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBetType = value!;
                                selectedNumbers.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 投注选项
                    _buildBetOptions(),
                    
                    const SizedBox(height: 12),
                    
                    // 投注金额
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '投注金额: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [10, 50, 100, 500].map((amount) => ElevatedButton(
                            onPressed: () => setState(() {
                              betAmount = amount;
                              _customAmountController.clear();
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: betAmount == amount ? Colors.red : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(55, 32),
                            ),
                            child: Text('$amount'),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '自定义金额',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    int? customAmount = int.tryParse(value);
                                    if (customAmount != null && customAmount > 0) {
                                      setState(() {
                                        betAmount = customAmount;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                String text = _customAmountController.text;
                                if (text.isNotEmpty) {
                                  int? customAmount = int.tryParse(text);
                                  if (customAmount != null && customAmount > 0 && customAmount <= balance) {
                                    setState(() {
                                      betAmount = customAmount;
                                    });
                                  } else {
                                    Get.snackbar('提示', '请输入有效的金额（1-$balance）');
                                  }
                                } else {
                                  Get.snackbar('提示', '请输入投注金额');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('确认'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 查看记录按钮
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BetRecordsPage(
                                 betRecords: betRecords.map((record) => BetRecord(
                                   betType: record.betType,
                                   amount: record.betAmount.toDouble(),
                                   result: record.result,
                                   diceNumbers: record.resultNumbers,
                                   sum: record.resultSum,
                                   timestamp: record.time,
                                   isWin: record.isWin,
                                   winAmount: record.winAmount.toDouble(),
                                 )).toList(),
                               ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history, color: Colors.white),
                        label: Text(
                          '查看下注记录 (${betRecords.length})',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3460),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建骰子
  Widget _buildDice(int number) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
  
  // 构建投注选项
  Widget _buildBetOptions() {
    switch (selectedBetType) {
      case '大小':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !isRolling ? () => setState(() => selectedNumbers = [1]) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedNumbers.contains(1) ? Colors.red : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('大 (11-18)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: !isRolling ? () => setState(() => selectedNumbers = [0]) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedNumbers.contains(0) ? Colors.red : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('小 (3-10)'),
              ),
            ),
          ],
        );
      case '单双':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !isRolling ? () => setState(() => selectedNumbers = [1]) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedNumbers.contains(1) ? Colors.red : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('单'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: !isRolling ? () => setState(() => selectedNumbers = [0]) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedNumbers.contains(0) ? Colors.red : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text('双'),
              ),
            ),
          ],
        );
      default:
        return ElevatedButton(
          onPressed: !isRolling ? () => setState(() => selectedNumbers = [1]) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedNumbers.isNotEmpty ? Colors.red : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: Text('选择 $selectedBetType'),
        );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/account_book_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/account_controller.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountBookController accountBookController = Get.find<AccountBookController>();
    final CategoryController categoryController = Get.find<CategoryController>();
    final AccountController accountController = Get.find<AccountController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('记账统计'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (accountBookController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (accountBookController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  accountBookController.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    accountBookController.loadAccountBooks();
                    categoryController.loadCategories();
                    accountController.loadAccounts();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 总览卡片
              _buildOverviewCards(accountBookController),
              const SizedBox(height: 24),
              
              // 收支趋势图
              _buildTrendChart(accountBookController),
              const SizedBox(height: 24),
              
              // 分类统计
              _buildCategoryStats(accountBookController, categoryController),
              const SizedBox(height: 24),
              
              // 账户统计
              _buildAccountStats(accountBookController, accountController, categoryController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOverviewCards(AccountBookController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '总收入',
            '¥${controller.getTotalIncome().toStringAsFixed(2)}',
            Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '总支出',
            '¥${controller.totalExpense.value.toStringAsFixed(2)}',
            Colors.red,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '净收入',
            '¥${(controller.getTotalIncome() - controller.totalExpense.value).toStringAsFixed(2)}',
            Colors.blue,
            Icons.account_balance,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(AccountBookController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收支趋势',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateTrendData(controller, true), // 收入
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _generateTrendData(controller, false), // 支出
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
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

  List<FlSpot> _generateTrendData(AccountBookController controller, bool isIncome) {
    // 简化的趋势数据生成，实际应用中应该根据真实交易数据计算
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      double value = isIncome 
          ? (controller.getTotalIncome() / 7) + (i * 100)
          : (controller.totalExpense.value / 7) + (i * 80);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Widget _buildCategoryStats(AccountBookController accountBookController, CategoryController categoryController) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分类统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryController.categories.map((category) {
              // 计算该分类的交易总额
              double categoryTotal = accountBookController.accountBooks
                  .where((t) => t.categoryId == category.id)
                  .fold(0.0, (sum, t) => sum + t.amount);
              
              return ListTile(
                leading: Icon(
                  category.icon != null 
                      ? IconData(int.parse(category.icon!), fontFamily: 'MaterialIcons')
                      : Icons.category,
                  color: category.type == '支出' ? Colors.red : Colors.green,
                ),
                title: Text(category.name),
                subtitle: Text(category.type),
                trailing: Text(
                  '¥${categoryTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category.type == '支出' ? Colors.red : Colors.green,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats(AccountBookController accountBookController, AccountController accountController, CategoryController categoryController) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '账户统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...accountController.accounts.map((account) {
              // 计算该账户的交易总额
              double accountTotal = accountBookController.accountBooks
                  .where((t) => t.accountId == account.id)
                  .fold(0.0, (sum, t) {
                    // 通过分类ID查找分类类型
                    final category = categoryController.categories
                        .firstWhereOrNull((c) => c.id == t.categoryId);
                    final isIncome = category?.type == '收入';
                    return sum + (isIncome ? t.amount : -t.amount);
                  });
              
              return ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                title: Text(account.name),
                subtitle: Text(account.type),
                trailing: Text(
                  '¥${(account.initialAmount + accountTotal).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
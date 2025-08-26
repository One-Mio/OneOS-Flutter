import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/account_book_controller.dart';
import 'add_account_book_page.dart';

class FinanceMainPage extends StatefulWidget {
  const FinanceMainPage({super.key});

  @override
  State<FinanceMainPage> createState() => _FinanceMainPageState();
}

class _FinanceMainPageState extends State<FinanceMainPage> {
  @override
  void initState() {
    super.initState();
    // 初始化记账相关控制器
    Get.put(AccountController());
    Get.put(CategoryController());
    final accountBookController = Get.put(AccountBookController());
    
    // 确保控制器初始化完成后再加载当前选择月份数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        accountBookController.loadSelectedMonthAccountBooks();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FinanceDashboard();
  }
}

class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

  Future<void> _refreshData() async {
    final accountBookController = Get.find<AccountBookController>();
    final accountController = Get.find<AccountController>();
    
    // 刷新账本数据
    await accountBookController.loadAccountBooks(refresh: true);
    // 刷新账户数据
    await accountController.loadAccounts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        children: [
          // 固定的总资产卡片
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildBalanceCard(),
          ),
          const SizedBox(height: 12),
          // 可滑动的记录列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildRecordsList(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() {
        final controller = Get.find<AccountBookController>();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => controller.goToPreviousMonth(),
              icon: const Icon(Icons.chevron_left, color: Colors.black87),
            ),
            Text(
              controller.getCurrentMonthString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            IconButton(
              onPressed: () => controller.goToNextMonth(),
              icon: const Icon(Icons.chevron_right, color: Colors.black87),
            ),
          ],
        );
      }),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const AddAccountBookPage()),
      backgroundColor: const Color(0xFF007AFF),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('记一笔'),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '总资产',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          GetBuilder<AccountController>(
            builder: (controller) {
              if (controller.isLoading.value && controller.accounts.isEmpty) {
                return Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }
              double totalBalance = controller.accounts
                  .fold(0.0, (sum, account) => sum + account.initialAmount);
              return Text(
                  '¥${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('本月收入', true),
              ),
              Expanded(
                child: _buildStatItem('本月支出', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final controller = Get.find<AccountBookController>();
          if (controller.isLoading.value && controller.accountBooks.isEmpty) {
            return Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }
          
          final currentMonth = controller.currentMonth.value;
          final records = controller.accountBooks.where((t) => 
              (isIncome ? t.amount > 0 : t.amount < 0) &&
              t.accountBookDate.year == currentMonth.year &&
              t.accountBookDate.month == currentMonth.month
          ).toList();
          
          double amount = records.fold(0.0, (sum, t) => 
              sum + (isIncome ? t.amount : t.amount.abs()));
          
          return Text(
            '¥${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    return Obx(() {
      final controller = Get.find<AccountBookController>();
      
      if (controller.isLoading.value && controller.accountBooks.isEmpty) {
        return _buildSkeletonLoader();
      }
      
      final currentMonth = controller.currentMonth.value;
      final monthlyAccountBooks = controller.accountBooks.where((accountBook) {
        return accountBook.accountBookDate.year == currentMonth.year &&
               accountBook.accountBookDate.month == currentMonth.month;
      }).toList();
      
      if (monthlyAccountBooks.isEmpty && !controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  '本月暂无记账记录',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // 按日期分组并排序
      Map<String, List<dynamic>> groupedAccountBooks = {};
      for (var accountBook in monthlyAccountBooks) {
        String dateKey = '${accountBook.accountBookDate.year}-${accountBook.accountBookDate.month.toString().padLeft(2, '0')}-${accountBook.accountBookDate.day.toString().padLeft(2, '0')}';
        if (!groupedAccountBooks.containsKey(dateKey)) {
          groupedAccountBooks[dateKey] = [];
        }
        groupedAccountBooks[dateKey]!.add(accountBook);
      }
      
      var sortedDates = groupedAccountBooks.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      
      return Column(
        children: sortedDates.map((dateKey) {
          final accountBooks = groupedAccountBooks[dateKey]!;
          final date = DateTime.parse(dateKey);
          final dayIncome = accountBooks.where((t) => t.amount > 0).fold(0.0, (sum, t) => sum + t.amount);
          final dayExpense = accountBooks.where((t) => t.amount < 0).fold(0.0, (sum, t) => sum + t.amount.abs());
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                // 日期头部
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${date.month}月${date.day}日',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          if (dayIncome > 0) ...[
                            Text(
                              '+¥${dayIncome.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (dayExpense > 0)
                            Text(
                              '-¥${dayExpense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 交易列表
                ...accountBooks.map((accountBook) => _buildRecordItem(accountBook)),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildRecordItem(dynamic accountBook) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GetBuilder<CategoryController>(
            builder: (categoryController) {
              final category = categoryController.categories
                  .firstWhereOrNull((c) => c.id == accountBook.categoryId);
              
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accountBook.amount > 0 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: category?.icon != null && category!.icon!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.network(
                          'http://120.79.186.102:5396/api/files/account_book_categories/${category.id}/${category.icon!}',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            accountBook.amount > 0 ? Colors.green : Colors.red,
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (context) => Icon(
                            accountBook.amount > 0 ? Icons.trending_up : Icons.trending_down,
                            color: accountBook.amount > 0 ? Colors.green : Colors.red,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        accountBook.amount > 0 ? Icons.trending_up : Icons.trending_down,
                        color: accountBook.amount > 0 ? Colors.green : Colors.red,
                        size: 24,
                      ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<CategoryController>(
                  builder: (categoryController) {
                    final category = categoryController.categories
                        .firstWhereOrNull((c) => c.id == accountBook.categoryId);
                    
                    String displayText;
                    if (accountBook.description?.isNotEmpty ?? false) {
                      displayText = accountBook.description!;
                    } else if (category != null) {
                      displayText = category.name;
                    } else {
                      displayText = '未知分类';
                    }
                    
                    return Text(
                      displayText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  accountBook.formattedCreatedTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${accountBook.amount > 0 ? '+' : ''}¥${accountBook.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accountBook.amount > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(3, (index) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      )),
    );
  }

  // 显示当前月份的所有记录

}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/account_book_controller.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/account_book_model.dart';
import '../../models/account_model.dart';
import '../../models/category_model.dart';

class AccountBookPage extends StatelessWidget {
  const AccountBookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountBookController controller = Get.put(AccountBookController());
    final AccountController accountController = Get.put(AccountController());
    final CategoryController categoryController = Get.put(CategoryController());
    
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAccountBooks();
      accountController.loadAccounts();
      categoryController.loadCategories();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('记账记录'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller, accountController, categoryController),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountBookDialog(context, controller, accountController, categoryController),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息卡片
          _buildStatisticsCard(controller),
          // 记账列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.refreshAccountBooks(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.accountBooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无记账记录',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddAccountBookDialog(context, controller, accountController, categoryController),
                        child: const Text('添加记账'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshAccountBooks(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.accountBooks.length,
                  itemBuilder: (context, index) {
                    final accountBook = controller.accountBooks[index];
                    return _buildAccountBookCard(context, accountBook, controller, accountController, categoryController);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(AccountBookController controller) {
    return Obx(() {
      final totalIncome = controller.getTotalIncome();
      final totalExpense = controller.getTotalExpense();
      final balance = controller.getBalance();

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('收入', totalIncome, Colors.green.shade300, Icons.trending_up),
                _buildStatItem('支出', totalExpense, Colors.red.shade300, Icons.trending_down),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '余额: ¥${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountBookCard(BuildContext context, AccountBookModel accountBook, AccountBookController controller, AccountController accountController, CategoryController categoryController) {
    final account = accountController.getAccountById(accountBook.accountId);
    final category = categoryController.getCategoryById(accountBook.categoryId);
    final isIncome = accountBook.isIncome;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          child: Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category?.name ?? '未知分类',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}¥${accountBook.getAbsoluteAmount().toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('账户: ${account?.name ?? '未知账户'}'),
            Text('时间: ${_formatDate(accountBook.accountBookDate)}'),
            if (accountBook.description?.isNotEmpty == true)
              Text('备注: ${accountBook.description}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditAccountBookDialog(context, accountBook, controller, accountController, categoryController);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, accountBook, controller);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, AccountBookController controller, AccountController accountController, CategoryController categoryController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选记账'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 这里可以添加筛选选项
            const Text('筛选功能开发中...'),
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
              // 应用筛选
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }

  void _showAddAccountBookDialog(BuildContext context, AccountBookController controller, AccountController accountController, CategoryController categoryController) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    AccountModel? selectedAccount;
    CategoryModel? selectedCategory;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加记账'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: '金额',
                    border: OutlineInputBorder(),
                    prefixText: '¥',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<AccountModel>(
                  value: selectedAccount,
                  decoration: const InputDecoration(
                    labelText: '账户',
                    border: OutlineInputBorder(),
                  ),
                  items: accountController.accounts.map((account) => DropdownMenuItem(
                    value: account,
                    child: Text(account.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccount = value;
                    });
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryController.categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text('${category.name} (${category.type})'),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                )),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('交易日期'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '备注（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.trim().isEmpty ||
                    selectedAccount == null ||
                    selectedCategory == null) {
                  Get.snackbar('错误', '请填写所有必填字段');
                  return;
                }

                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  Get.snackbar('错误', '请输入有效的金额');
                  return;
                }

                // 根据分类类型确定金额正负
                final finalAmount = selectedCategory!.type == '支出' ? -amount : amount;

                final success = await controller.createAccountBook(
                  amount: finalAmount,
                  accountId: selectedAccount!.id,
                  categoryId: selectedCategory!.id,
                  accountBookDate: selectedDate,
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                );

                if (success) {
                  Navigator.of(context).pop();
                  Get.snackbar('成功', '交易添加成功');
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAccountBookDialog(BuildContext context, AccountBookModel accountBook, AccountBookController controller, AccountController accountController, CategoryController categoryController) {
    final amountController = TextEditingController(text: accountBook.getAbsoluteAmount().toString());
    final descriptionController = TextEditingController(text: accountBook.description ?? '');
    AccountModel? selectedAccount = accountController.getAccountById(accountBook.accountId);
    CategoryModel? selectedCategory = categoryController.getCategoryById(accountBook.categoryId);
    DateTime selectedDate = accountBook.accountBookDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑记账'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: '金额',
                    border: OutlineInputBorder(),
                    prefixText: '¥',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<AccountModel>(
                  value: selectedAccount,
                  decoration: const InputDecoration(
                    labelText: '账户',
                    border: OutlineInputBorder(),
                  ),
                  items: accountController.accounts.map((account) => DropdownMenuItem(
                    value: account,
                    child: Text(account.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccount = value;
                    });
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryController.categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text('${category.name} (${category.type})'),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                )),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('交易日期'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '备注（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.trim().isEmpty ||
                    selectedAccount == null ||
                    selectedCategory == null) {
                  Get.snackbar('错误', '请填写所有必填字段');
                  return;
                }

                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  Get.snackbar('错误', '请输入有效的金额');
                  return;
                }

                // 根据分类类型确定金额正负
                final finalAmount = selectedCategory!.type == '支出' ? -amount : amount;

                final success = await controller.updateAccountBook(
                  accountBook.id,
                  amount: finalAmount,
                  accountId: selectedAccount!.id,
                  categoryId: selectedCategory!.id,
                  accountBookDate: selectedDate,
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                );

                if (success) {
                  Navigator.of(context).pop();
                  Get.snackbar('成功', '记账更新成功');
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AccountBookModel accountBook, AccountBookController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记账记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.deleteAccountBook(accountBook.id);
              Navigator.of(context).pop();
              if (success) {
                Get.snackbar('成功', '记账删除成功');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
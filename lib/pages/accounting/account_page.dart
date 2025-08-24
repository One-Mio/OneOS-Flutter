import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/account_controller.dart';
import '../../models/account_model.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountController controller = Get.put(AccountController());
    
    // 初始化时加载账户数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAccounts();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
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
                  onPressed: () => controller.refreshAccounts(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (controller.accounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  '暂无账户',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddAccountDialog(context, controller),
                  child: const Text('添加账户'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAccounts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.accounts.length,
            itemBuilder: (context, index) {
              final account = controller.accounts[index];
              return _buildAccountCard(context, account, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildAccountCard(BuildContext context, AccountModel account, AccountController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${account.type}'),
            Text('初始金额: ¥${account.initialAmount.toStringAsFixed(2)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditAccountDialog(context, account, controller);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, account, controller);
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

  void _showAddAccountDialog(BuildContext context, AccountController controller) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '账户名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: '账户类型',
                border: OutlineInputBorder(),
                hintText: '如：现金、银行卡、支付宝等',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: '初始金额',
                border: OutlineInputBorder(),
                prefixText: '¥',
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
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  typeController.text.trim().isEmpty ||
                  amountController.text.trim().isEmpty) {
                Get.snackbar('错误', '请填写所有字段');
                return;
              }

              final amount = double.tryParse(amountController.text.trim());
              if (amount == null) {
                Get.snackbar('错误', '请输入有效的金额');
                return;
              }

              final success = await controller.createAccount(
                name: nameController.text.trim(),
                type: typeController.text.trim(),
                initialAmount: amount,
              );

              if (success) {
                Navigator.of(context).pop();
                Get.snackbar('成功', '账户添加成功');
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, AccountModel account, AccountController controller) {
    final nameController = TextEditingController(text: account.name);
    final typeController = TextEditingController(text: account.type);
    final amountController = TextEditingController(text: account.initialAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '账户名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: '账户类型',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: '初始金额',
                border: OutlineInputBorder(),
                prefixText: '¥',
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
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  typeController.text.trim().isEmpty ||
                  amountController.text.trim().isEmpty) {
                Get.snackbar('错误', '请填写所有字段');
                return;
              }

              final amount = double.tryParse(amountController.text.trim());
              if (amount == null) {
                Get.snackbar('错误', '请输入有效的金额');
                return;
              }

              final success = await controller.updateAccount(
                account.id,
                name: nameController.text.trim(),
                type: typeController.text.trim(),
                initialAmount: amount,
              );

              if (success) {
                Navigator.of(context).pop();
                Get.snackbar('成功', '账户更新成功');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AccountModel account, AccountController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账户 "${account.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.deleteAccount(account.id);
              Navigator.of(context).pop();
              if (success) {
                Get.snackbar('成功', '账户删除成功');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
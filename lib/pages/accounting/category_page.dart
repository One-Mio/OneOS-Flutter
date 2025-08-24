import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());
    
    // 初始化时加载分类数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCategories();
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('分类管理'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '支出分类'),
              Tab(text: '收入分类'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCategoryDialog(context, controller),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(context, controller, '支出'),
            _buildCategoryList(context, controller, '收入'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryController controller, String type) {
    return Obx(() {
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
                onPressed: () => controller.refreshCategories(),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }

      final categories = controller.getCategoriesByType(type);
      final topLevelCategories = categories.where((c) => c.isTopLevel).toList();

      if (topLevelCategories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '暂无${type}分类',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddCategoryDialog(context, controller, type: type),
                child: Text('添加${type}分类'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshCategories(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: topLevelCategories.length,
          itemBuilder: (context, index) {
            final category = topLevelCategories[index];
            final subCategories = categories.where((c) => c.ownerId == category.id).toList();
            return _buildCategoryCard(context, category, controller, subCategories);
          },
        ),
      );
    });
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category, CategoryController controller, List<CategoryModel> subCategories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: category.type == '支出' ? Colors.red : Colors.green,
          child: Icon(
            Icons.category,
            color: Colors.white,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${category.type} • ${subCategories.length} 个子分类'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'add_sub':
                _showAddCategoryDialog(context, controller, parentCategory: category);
                break;
              case 'edit':
                _showEditCategoryDialog(context, category, controller);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, category, controller);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_sub',
              child: Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('添加子分类'),
                ],
              ),
            ),
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
        children: subCategories.map((subCategory) => _buildSubCategoryTile(context, subCategory, controller)).toList(),
      ),
    );
  }

  Widget _buildSubCategoryTile(BuildContext context, CategoryModel subCategory, CategoryController controller) {
    return ListTile(
      leading: const SizedBox(width: 16),
      title: Row(
        children: [
          Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(subCategory.name),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showEditCategoryDialog(context, subCategory, controller);
              break;
            case 'delete':
              _showDeleteConfirmDialog(context, subCategory, controller);
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
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryController controller, {String? type, CategoryModel? parentCategory}) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    String selectedType = type ?? parentCategory?.type ?? '支出';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(parentCategory != null ? '添加子分类' : '添加分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标文件名（可选）',
                  border: OutlineInputBorder(),
                  hintText: '如：food.png',
                ),
              ),
              if (parentCategory == null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '分类类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '支出', child: Text('支出')),
                    DropdownMenuItem(value: '收入', child: Text('收入')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar('错误', '请输入分类名称');
                  return;
                }

                final success = await controller.createCategory(
                  name: nameController.text.trim(),
                  type: selectedType,
                  icon: iconController.text.trim().isEmpty ? null : iconController.text.trim(),
                  ownerId: parentCategory?.id,
                );

                if (success) {
                  Navigator.of(context).pop();
                  Get.snackbar('成功', '分类添加成功');
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category, CategoryController controller) {
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon ?? '');
    String selectedType = category.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标文件名（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
              if (category.isTopLevel) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '分类类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '支出', child: Text('支出')),
                    DropdownMenuItem(value: '收入', child: Text('收入')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar('错误', '请输入分类名称');
                  return;
                }

                final success = await controller.updateCategory(
                  category.id,
                  name: nameController.text.trim(),
                  type: selectedType,
                  icon: iconController.text.trim().isEmpty ? null : iconController.text.trim(),
                  ownerId: category.ownerId,
                );

                if (success) {
                  Navigator.of(context).pop();
                  Get.snackbar('成功', '分类更新成功');
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, CategoryModel category, CategoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类 "${category.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.deleteCategory(category.id);
              Navigator.of(context).pop();
              if (success) {
                Get.snackbar('成功', '分类删除成功');
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
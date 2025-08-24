import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final PocketBaseService _pbService = Get.find<PocketBaseService>();
  
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> topLevelCategories = <CategoryModel>[].obs;
  final RxMap<String, List<CategoryModel>> subCategories = <String, List<CategoryModel>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  int _currentPage = 1;
  final int _perPage = 30;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadTopLevelCategories();
  }

  // 加载所有分类
  Future<void> loadCategories({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      categories.clear();
      hasMore.value = true;
    }
    
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getCategories(
        page: _currentPage,
        perPage: _perPage,
      );
      
      if (response != null) {
        if (refresh) {
          categories.value = response.items;
        } else {
          categories.addAll(response.items);
        }
        
        hasMore.value = _currentPage < response.totalPages;
        _currentPage++;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = '加载分类列表失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 加载一级分类
  Future<void> loadTopLevelCategories() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getTopLevelCategories();
      
      if (response != null) {
        topLevelCategories.value = response.items;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = '加载一级分类失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 加载二级分类
  Future<void> loadSubCategories(String parentId) async {
    if (subCategories.containsKey(parentId)) {
      return; // 已经加载过了
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getSubCategories(parentId);
      
      if (response != null) {
        subCategories[parentId] = response.items;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = '加载二级分类失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 创建分类
  Future<bool> createCategory({
    required String name,
    required String type,
    String? icon,
    String? ownerId,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage.value = '分类名称不能为空';
      return false;
    }
    
    if (type.trim().isEmpty) {
      errorMessage.value = '分类类型不能为空';
      return false;
    }
    
    if (!['支出', '收入'].contains(type.trim())) {
      errorMessage.value = '分类类型必须是"支出"或"收入"';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final category = await _pbService.createCategory(
        name: name.trim(),
        type: type.trim(),
        icon: icon,
        ownerId: ownerId,
      );
      
      if (category != null) {
        categories.insert(0, category);
        
        // 如果是一级分类，添加到一级分类列表
        if (category.isTopLevel) {
          topLevelCategories.insert(0, category);
        } else if (ownerId != null) {
          // 如果是二级分类，添加到对应的二级分类列表
          if (subCategories.containsKey(ownerId)) {
            subCategories[ownerId]!.insert(0, category);
          } else {
            subCategories[ownerId] = [category];
          }
        }
        
        Get.snackbar('成功', '分类创建成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '创建分类失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 更新分类
  Future<bool> updateCategory(
    String id, {
    String? name,
    String? type,
    String? icon,
    String? ownerId,
  }) async {
    if (name != null && name.trim().isEmpty) {
      errorMessage.value = '分类名称不能为空';
      return false;
    }
    
    if (type != null && type.trim().isEmpty) {
      errorMessage.value = '分类类型不能为空';
      return false;
    }
    
    if (type != null && !['支出', '收入'].contains(type.trim())) {
      errorMessage.value = '分类类型必须是"支出"或"收入"';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final updatedCategory = await _pbService.updateCategory(
        id,
        name: name?.trim(),
        type: type?.trim(),
        icon: icon,
        ownerId: ownerId,
      );
      
      if (updatedCategory != null) {
        // 更新所有分类列表中的项目
        final index = categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          categories[index] = updatedCategory;
        }
        
        // 更新一级分类列表
        final topIndex = topLevelCategories.indexWhere((category) => category.id == id);
        if (topIndex != -1) {
          if (updatedCategory.isTopLevel) {
            topLevelCategories[topIndex] = updatedCategory;
          } else {
            topLevelCategories.removeAt(topIndex);
          }
        } else if (updatedCategory.isTopLevel) {
          topLevelCategories.add(updatedCategory);
        }
        
        // 更新二级分类列表
        subCategories.forEach((parentId, subCats) {
          final subIndex = subCats.indexWhere((category) => category.id == id);
          if (subIndex != -1) {
            if (updatedCategory.ownerId == parentId) {
              subCats[subIndex] = updatedCategory;
            } else {
              subCats.removeAt(subIndex);
            }
          }
        });
        
        // 如果更新后的分类有新的父分类，添加到对应列表
        if (!updatedCategory.isTopLevel && updatedCategory.ownerId != null) {
          final parentId = updatedCategory.ownerId!;
          if (subCategories.containsKey(parentId)) {
            final exists = subCategories[parentId]!.any((cat) => cat.id == id);
            if (!exists) {
              subCategories[parentId]!.add(updatedCategory);
            }
          } else {
            subCategories[parentId] = [updatedCategory];
          }
        }
        
        Get.snackbar('成功', '分类更新成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新分类失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 删除分类
  Future<bool> deleteCategory(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final success = await _pbService.deleteCategory(id);
      
      if (success) {
        // 从所有列表中移除
        categories.removeWhere((category) => category.id == id);
        topLevelCategories.removeWhere((category) => category.id == id);
        
        subCategories.forEach((parentId, subCats) {
          subCats.removeWhere((category) => category.id == id);
        });
        
        Get.snackbar('成功', '分类删除成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '删除分类失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 刷新分类列表
  Future<void> refreshCategories() async {
    await loadCategories(refresh: true);
    await loadTopLevelCategories();
    subCategories.clear();
  }

  // 获取指定分类
  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取指定类型的一级分类
  List<CategoryModel> getTopLevelCategoriesByType(String type) {
    return topLevelCategories.where((category) => category.type == type).toList();
  }

  // 获取指定父分类的二级分类
  List<CategoryModel> getSubCategoriesByParent(String parentId) {
    return subCategories[parentId] ?? [];
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
  }

  // 根据类型获取分类列表
  List<CategoryModel> getCategoriesByType(String type) {
    return categories.where((category) => category.type == type).toList();
  }
}
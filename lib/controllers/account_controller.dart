import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../models/account_model.dart';

class AccountController extends GetxController {
  final PocketBaseService _pbService = Get.find<PocketBaseService>();
  
  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  int _currentPage = 1;
  final int _perPage = 30;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  // 加载账户列表
  Future<void> loadAccounts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      accounts.clear();
      hasMore.value = true;
    }
    
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getAccounts(
        page: _currentPage,
        perPage: _perPage,
      );
      
      if (response != null) {
        if (refresh) {
          accounts.value = response.items;
        } else {
          accounts.addAll(response.items);
        }
        
        hasMore.value = _currentPage < response.totalPages;
        _currentPage++;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = '加载账户列表失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 创建账户
  Future<bool> createAccount({
    required String name,
    required String type,
    required double initialAmount,
  }) async {
    if (name.trim().isEmpty) {
      errorMessage.value = '账户名称不能为空';
      return false;
    }
    
    if (type.trim().isEmpty) {
      errorMessage.value = '账户类型不能为空';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final account = await _pbService.createAccount(
        name: name.trim(),
        type: type.trim(),
        initialAmount: initialAmount,
      );
      
      if (account != null) {
        accounts.insert(0, account);
        Get.snackbar('成功', '账户创建成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '创建账户失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 更新账户
  Future<bool> updateAccount(
    String id, {
    String? name,
    String? type,
    double? initialAmount,
  }) async {
    if (name != null && name.trim().isEmpty) {
      errorMessage.value = '账户名称不能为空';
      return false;
    }
    
    if (type != null && type.trim().isEmpty) {
      errorMessage.value = '账户类型不能为空';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final updatedAccount = await _pbService.updateAccount(
        id,
        name: name?.trim(),
        type: type?.trim(),
        initialAmount: initialAmount,
      );
      
      if (updatedAccount != null) {
        final index = accounts.indexWhere((account) => account.id == id);
        if (index != -1) {
          accounts[index] = updatedAccount;
        }
        Get.snackbar('成功', '账户更新成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新账户失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 删除账户
  Future<bool> deleteAccount(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final success = await _pbService.deleteAccount(id);
      
      if (success) {
        accounts.removeWhere((account) => account.id == id);
        Get.snackbar('成功', '账户删除成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '删除账户失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 刷新账户列表
  Future<void> refreshAccounts() async {
    await loadAccounts(refresh: true);
  }

  // 获取指定账户
  AccountModel? getAccountById(String id) {
    try {
      return accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
  }
}
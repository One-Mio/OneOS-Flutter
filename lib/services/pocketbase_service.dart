import 'dart:convert';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/account_book_model.dart';
import '../models/endowment_insurance_model.dart';

class PocketBaseService extends GetxService {
  late PocketBase pb;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;

  // 持久化存储的键
  static const String _tokenKey = 'admin_auth_token';
  static const String _modelKey = 'admin_auth_model';
  static const String _serverUrlKey = 'server_url';
  
  // 默认服务器地址
  String _currentServerUrl = 'http://120.79.186.102:5396';
  
  Future<PocketBaseService> init() async {
    // 从持久化存储加载服务器地址
    await _loadServerUrl();
    // 初始化PocketBase实例
    pb = PocketBase(_currentServerUrl);
    // 尝试从持久化存储恢复登录状态
    await _loadAuthFromStorage();
    return this;
  }
  
  // 从持久化存储加载服务器地址
  Future<void> _loadServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_serverUrlKey);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _currentServerUrl = savedUrl;
      }
    } catch (e) {
      print('加载服务器地址时出错: $e');
    }
  }
  
  // 保存服务器地址到持久化存储
  Future<void> _saveServerUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_serverUrlKey, url);
    } catch (e) {
      print('保存服务器地址时出错: $e');
    }
  }
  
  // 更新服务器地址
  void updateServerUrl(String newUrl) {
    if (newUrl != _currentServerUrl) {
      _currentServerUrl = newUrl;
      pb = PocketBase(_currentServerUrl);
      _saveServerUrl(newUrl);
      // 清除之前的认证状态，因为服务器已更改
      logout();
    }
  }
  
  // 获取当前服务器地址
  String get currentServerUrl => _currentServerUrl;
  
  // 从持久化存储加载认证信息
  Future<void> _loadAuthFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final model = prefs.getString(_modelKey);
      
      if (token != null && model != null) {
        // 恢复认证状态
        pb.authStore.save(token, RecordModel.fromJson(jsonDecode(model)));
        isAuthenticated.value = pb.authStore.isValid;
      }
    } catch (e) {
      print('加载认证信息时出错: $e');
    }
  }
  
  // 保存认证信息到持久化存储
  Future<void> _saveAuthToStorage() async {
    try {
      if (pb.authStore.isValid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, pb.authStore.token);
        if (pb.authStore.record != null) {
          await prefs.setString(_modelKey, jsonEncode(pb.authStore.record!.toJson()));
        }
      }
    } catch (e) {
      print('保存认证信息时出错: $e');
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    try {
      // 清除之前的错误信息
      errorMessage.value = '';
      
      // 尝试管理员登录
      await pb.collection('_superusers').authWithPassword(email, password);
      
      // 如果成功，更新认证状态并保存到持久化存储
      isAuthenticated.value = pb.authStore.isValid;
      if (isAuthenticated.value) {
        await _saveAuthToStorage();
      }
      return isAuthenticated.value;
    } catch (e) {
      // 处理错误
      errorMessage.value = e.toString();
      isAuthenticated.value = false;
      return false;
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
    isAuthenticated.value = false;
    
    // 清除持久化存储的认证信息
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_modelKey);
    } catch (e) {
      print('清除认证信息时出错: $e');
    }
  }

  bool get isLoggedIn => isAuthenticated.value;

  // ==================== 记账相关API ====================
  
  // 获取账户列表
  Future<AccountListResponse?> getAccounts({int page = 1, int perPage = 30}) async {
    try {
      final result = await pb.collection('accounts').getList(
        page: page,
        perPage: perPage,
      );
      return AccountListResponse.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '获取账户列表失败: $e';
      return null;
    }
  }

  // 创建账户
  Future<AccountModel?> createAccount({
    required String name,
    required String type,
    required double initialAmount,
  }) async {
    try {
      final result = await pb.collection('accounts').create(body: {
        'name': name,
        'type': type,
        'initial_amount': initialAmount,
      });
      return AccountModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '创建账户失败: $e';
      return null;
    }
  }

  // 更新账户
  Future<AccountModel?> updateAccount(
    String id, {
    String? name,
    String? type,
    double? initialAmount,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (initialAmount != null) body['initial_amount'] = initialAmount;
      
      final result = await pb.collection('accounts').update(id, body: body);
      return AccountModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '更新账户失败: $e';
      return null;
    }
  }

  // 删除账户
  Future<bool> deleteAccount(String id) async {
    try {
      await pb.collection('accounts').delete(id);
      return true;
    } catch (e) {
      errorMessage.value = '删除账户失败: $e';
      return false;
    }
  }

  // 获取分类列表
  Future<CategoryListResponse?> getCategories({int page = 1, int perPage = 30, String? filter}) async {
    try {
      final result = await pb.collection('account_book_categories').getList(
        page: page,
        perPage: perPage,
        filter: filter,
      );
      return CategoryListResponse.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '获取分类列表失败: $e';
      return null;
    }
  }

  // 获取一级分类
  Future<CategoryListResponse?> getTopLevelCategories({int page = 1, int perPage = 30}) async {
    return getCategories(page: page, perPage: perPage, filter: 'owner_id = ""');
  }

  // 获取二级分类
  Future<CategoryListResponse?> getSubCategories(String parentId, {int page = 1, int perPage = 30}) async {
    return getCategories(page: page, perPage: perPage, filter: 'owner_id = "$parentId"');
  }

  // 创建分类
  Future<CategoryModel?> createCategory({
    required String name,
    required String type,
    String? icon,
    String? ownerId,
  }) async {
    try {
      final body = {
        'name': name,
        'type': type,
      };
      if (icon != null) body['icon'] = icon;
      if (ownerId != null) body['owner_id'] = ownerId;
      
      final result = await pb.collection('account_book_categories').create(body: body);
      return CategoryModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '创建分类失败: $e';
      return null;
    }
  }

  // 更新分类
  Future<CategoryModel?> updateCategory(
    String id, {
    String? name,
    String? type,
    String? icon,
    String? ownerId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (icon != null) body['icon'] = icon;
      if (ownerId != null) body['owner_id'] = ownerId;
      
      final result = await pb.collection('account_book_categories').update(id, body: body);
      return CategoryModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '更新分类失败: $e';
      return null;
    }
  }

  // 删除分类
  Future<bool> deleteCategory(String id) async {
    try {
      await pb.collection('account_book_categories').delete(id);
      return true;
    } catch (e) {
      errorMessage.value = '删除分类失败: $e';
      return false;
    }
  }

  // 获取记账记录列表
  Future<AccountBookListResponse?> getAccountBooks({int page = 1, int perPage = 30, String? filter, String? sort}) async {
    try {
      final result = await pb.collection('account_book').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort ?? '-transaction_date',
      );
      
      return AccountBookListResponse.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '获取记账记录失败: $e';
      return null;
    }
  }

  // 创建记账记录
  Future<AccountBookModel?> createAccountBook({
    required double amount,
    String? accountId, // 改为可选参数
    required String categoryId,
    required DateTime accountBookDate,
    String? description,
    String? attachment,
  }) async {
    try {
      final body = {
        'amount': amount,
        'category_id': categoryId,
        'transaction_date': accountBookDate.toIso8601String(),
      };
      // 只有当accountId不为null时才添加到body中
      if (accountId != null) body['account_id'] = accountId;
      if (description != null) body['description'] = description;
      if (attachment != null) body['attachment'] = attachment;
      
      final result = await pb.collection('account_book').create(body: body);
      return AccountBookModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '创建记账记录失败: $e';
      return null;
    }
  }

  // 更新记账记录
  Future<AccountBookModel?> updateAccountBook(
    String id, {
    double? amount,
    String? accountId,
    String? categoryId,
    DateTime? accountBookDate,
    String? description,
    String? attachment,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (amount != null) body['amount'] = amount;
      if (accountId != null) body['account_id'] = accountId;
      if (categoryId != null) body['category_id'] = categoryId;
      if (accountBookDate != null) body['transaction_date'] = accountBookDate.toIso8601String();
      if (description != null) body['description'] = description;
      if (attachment != null) body['attachment'] = attachment;
      
      final result = await pb.collection('account_book').update(id, body: body);
      return AccountBookModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '更新记账记录失败: $e';
      return null;
    }
  }

  // 删除记账记录
  Future<bool> deleteAccountBook(String id) async {
    try {
      await pb.collection('account_book').delete(id);
      return true;
    } catch (e) {
      errorMessage.value = '删除记账记录失败: $e';
      return false;
    }
  }

  // ==================== 养老保险相关API ====================
  
  // 获取养老保险记录列表
  Future<EndowmentInsuranceListResponse?> getEndowmentInsurance({int page = 1, int perPage = 30}) async {
    try {
      final result = await pb.collection('endowment_insurance').getList(
        page: page,
        perPage: perPage,
        sort: '-contribution_year_and_month',
      );
      return EndowmentInsuranceListResponse.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '获取养老保险记录失败: $e';
      return null;
    }
  }

  // 创建养老保险记录
  Future<EndowmentInsuranceModel?> createEndowmentInsurance({
    required String cityOfInsuranceParticipation,
    required String unitName,
    required double contributionBase,
    required double personalContribution,
    required double unitContribution,
    required String contributionYearAndMonth,
  }) async {
    try {
      final result = await pb.collection('endowment_insurance').create(body: {
        'city_of_insurance_participation': cityOfInsuranceParticipation,
        'unit_name': unitName,
        'contribution_base': contributionBase,
        'personal_contribution': personalContribution,
        'unit_contribution': unitContribution,
        'contribution_year_and_month': contributionYearAndMonth,
      });
      return EndowmentInsuranceModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '创建养老保险记录失败: $e';
      return null;
    }
  }

  // 更新养老保险记录
  Future<EndowmentInsuranceModel?> updateEndowmentInsurance(
    String id, {
    String? cityOfInsuranceParticipation,
    String? unitName,
    double? contributionBase,
    double? personalContribution,
    double? unitContribution,
    String? contributionYearAndMonth,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (cityOfInsuranceParticipation != null) body['city_of_insurance_participation'] = cityOfInsuranceParticipation;
      if (unitName != null) body['unit_name'] = unitName;
      if (contributionBase != null) body['contribution_base'] = contributionBase;
      if (personalContribution != null) body['personal_contribution'] = personalContribution;
      if (unitContribution != null) body['unit_contribution'] = unitContribution;
      if (contributionYearAndMonth != null) body['contribution_year_and_month'] = contributionYearAndMonth;
      
      final result = await pb.collection('endowment_insurance').update(id, body: body);
      return EndowmentInsuranceModel.fromJson(result.toJson());
    } catch (e) {
      errorMessage.value = '更新养老保险记录失败: $e';
      return null;
    }
  }

  // 删除养老保险记录
  Future<bool> deleteEndowmentInsurance(String id) async {
    try {
      await pb.collection('endowment_insurance').delete(id);
      return true;
    } catch (e) {
      errorMessage.value = '删除养老保险记录失败: $e';
      return false;
    }
  }

  // 获取养老保险统计数据（使用视图API）
  Future<Map<String, dynamic>?> getEndowmentInsuranceTotal() async {
    try {
      final result = await pb.collection('endowment_insurance_total').getList(
        page: 1,
        perPage: 30,
      );
      
      if (result.items.isNotEmpty) {
        final item = result.items.first;
        final data = item.toJson();
        
        // 解析JSON字符串中的数值
        double totalPersonal = 0.0;
        double totalUnit = 0.0;
        
        if (data['total_personal_contribution'] != null) {
          final personalStr = data['total_personal_contribution'].toString();
          totalPersonal = double.tryParse(personalStr) ?? 0.0;
        }
        
        if (data['total_unit_contribution'] != null) {
          final unitStr = data['total_unit_contribution'].toString();
          totalUnit = double.tryParse(unitStr) ?? 0.0;
        }
        
        // 获取城市缴费月数
        int shenzhenCount = 0;
        int dongguanCount = 0;
        
        if (data['shenzhen_count'] != null) {
          shenzhenCount = int.tryParse(data['shenzhen_count'].toString()) ?? 0;
        }
        
        if (data['dongguan_count'] != null) {
          dongguanCount = int.tryParse(data['dongguan_count'].toString()) ?? 0;
        }
        
        return {
          'total_personal_contribution': totalPersonal,
          'total_unit_contribution': totalUnit,
          'shenzhen_count': shenzhenCount,
          'dongguan_count': dongguanCount,
        };
      }
      
      return {
        'total_personal_contribution': 0.0,
        'total_unit_contribution': 0.0,
        'shenzhen_count': 0,
        'dongguan_count': 0,
      };
    } catch (e) {
      errorMessage.value = '获取养老保险统计数据失败: $e';
      return null;
    }
  }
}
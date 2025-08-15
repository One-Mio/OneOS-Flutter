import 'dart:convert';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        await prefs.setString(_modelKey, jsonEncode(pb.authStore.model.toJson()));
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
      final authData = await pb.admins.authWithPassword(email, password);
      
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
}
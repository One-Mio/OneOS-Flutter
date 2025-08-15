import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

class AuthController extends GetxController {
  final PocketBaseService _pbService = Get.find<PocketBaseService>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 登录方法
  Future<void> login(String email, String password, String serverUrl) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = '邮箱和密码不能为空';
      return;
    }

    if (serverUrl.isEmpty) {
      errorMessage.value = '服务器地址不能为空';
      return;
    }

    // 验证服务器地址格式
    if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
      errorMessage.value = '服务器地址必须以http://或https://开头';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 更新PocketBase服务器地址
      _pbService.updateServerUrl(serverUrl);
      
      final success = await _pbService.adminLogin(email, password);
      isLoading.value = false;

      if (success) {
        // 登录成功，跳转到首页
        Get.offAll(() => const HomePage());
      } else {
        // 登录失败，显示错误信息
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '登录过程中发生错误: $e';
    }
  }

  // 登出方法
  Future<void> logout() async {
    await _pbService.logout();
    // 登出后跳转到登录页面
    Get.offAll(() => LoginPage());
  }

  // 检查是否已登录
  bool get isLoggedIn => _pbService.isLoggedIn;

  // 显示登录页面
  void showLoginPage() {
    Get.to(() => LoginPage());
  }
}
import 'package:get/get.dart';
import '../models/pay_stub_model.dart';
import '../services/pocketbase_service.dart';

class PayStubController extends GetxController {
  final PocketBaseService _pocketBaseService = Get.find<PocketBaseService>();
  
  final RxList<PayStubModel> payStubs = <PayStubModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchPayStubs();
  }
  
  /// 获取薪资单列表
  Future<void> fetchPayStubs({int page = 1, int perPage = 30}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // 使用PocketBase SDK获取数据
      final resultList = await _pocketBaseService.pb.collection('pay_stub').getList(
        page: page,
        perPage: perPage,
      );
      
      // 转换数据
      final items = resultList.items.map((record) => 
        PayStubModel.fromJson(record.toJson())
      ).toList();
      
      if (page == 1) {
        payStubs.value = items;
      } else {
        payStubs.addAll(items);
      }
      
      currentPage.value = resultList.page;
      totalPages.value = resultList.totalPages;
      totalItems.value = resultList.totalItems;
      
    } catch (e) {
      errorMessage.value = '获取薪资单时发生错误: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 刷新薪资单列表
  Future<void> refreshPayStubs() async {
    currentPage.value = 1;
    await fetchPayStubs(page: 1);
  }
  
  /// 加载更多薪资单
  Future<void> loadMorePayStubs() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await fetchPayStubs(page: currentPage.value + 1);
    }
  }
  
  /// 根据年月筛选薪资单
  List<PayStubModel> getPayStubsByYearMonth(String yearMonth) {
    return payStubs.where((payStub) => payStub.paymentYearAndMonth == yearMonth).toList();
  }
  
  /// 获取所有不重复的年月
  List<String> getAvailableYearMonths() {
    final yearMonths = payStubs.map((payStub) => payStub.paymentYearAndMonth).toSet().toList();
    yearMonths.sort((a, b) => b.compareTo(a)); // 按时间倒序排列
    return yearMonths;
  }
  
  /// 计算总收入
  double getTotalIncome() {
    return payStubs.fold(0.0, (sum, payStub) => sum + payStub.netPay);
  }
  
  /// 计算平均收入
  double getAverageIncome() {
    if (payStubs.isEmpty) return 0.0;
    return getTotalIncome() / payStubs.length;
  }
}
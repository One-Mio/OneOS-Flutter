import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../models/endowment_insurance_model.dart';

class EndowmentInsuranceController extends GetxController {
  final PocketBaseService _pbService = Get.find<PocketBaseService>();
  
  final RxList<EndowmentInsuranceModel> endowmentInsuranceList = <EndowmentInsuranceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  // 从视图API获取的统计数据
  final RxDouble totalPersonalFromApi = 0.0.obs;
  final RxDouble totalUnitFromApi = 0.0.obs;
  final RxInt shenzhenMonthsFromApi = 0.obs;
  final RxInt dongguanMonthsFromApi = 0.obs;
  final RxBool isTotalLoading = false.obs;
  
  int _currentPage = 1;
  final int _perPage = 12;

  @override
  void onInit() {
    super.onInit();
    loadEndowmentInsurance();
    loadTotalContributions();
  }

  // 加载养老保险记录列表
  Future<void> loadEndowmentInsurance({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      endowmentInsuranceList.clear();
      hasMore.value = true;
    }
    
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getEndowmentInsurance(
        page: _currentPage,
        perPage: _perPage,
      );
      
      if (response != null) {
        if (refresh) {
          endowmentInsuranceList.value = response.items;
        } else {
          endowmentInsuranceList.addAll(response.items);
        }
        
        hasMore.value = _currentPage < response.totalPages;
        _currentPage++;
      } else {
        errorMessage.value = '加载养老保险记录失败';
      }
    } catch (e) {
      errorMessage.value = '加载养老保险记录时出错: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 加载统计数据（从视图API）
  Future<void> loadTotalContributions() async {
    isTotalLoading.value = true;
    
    try {
      final result = await _pbService.getEndowmentInsuranceTotal();
      
      if (result != null) {
        totalPersonalFromApi.value = result['total_personal_contribution'] ?? 0.0;
        totalUnitFromApi.value = result['total_unit_contribution'] ?? 0.0;
        shenzhenMonthsFromApi.value = result['shenzhen_count'] ?? 0;
        dongguanMonthsFromApi.value = result['dongguan_count'] ?? 0;
      } else {
        totalPersonalFromApi.value = 0.0;
        totalUnitFromApi.value = 0.0;
        shenzhenMonthsFromApi.value = 0;
        dongguanMonthsFromApi.value = 0;
      }
    } catch (e) {
      print('加载统计数据时出错: $e');
      totalPersonalFromApi.value = 0.0;
      totalUnitFromApi.value = 0.0;
      shenzhenMonthsFromApi.value = 0;
      dongguanMonthsFromApi.value = 0;
    } finally {
      isTotalLoading.value = false;
    }
  }

  // 刷新数据
  Future<void> refreshData() async {
    await Future.wait([
      loadEndowmentInsurance(refresh: true),
      loadTotalContributions(),
    ]);
  }

  // 加载更多数据
  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    await loadEndowmentInsurance();
  }

  // 加载更多数据
  Future<void> loadMoreData() async {
    if (!hasMore.value || isLoading.value) return;
    await loadEndowmentInsurance();
  }

  // 创建养老保险记录
  Future<bool> createEndowmentInsurance({
    required String cityOfInsuranceParticipation,
    required String unitName,
    required double contributionBase,
    required double personalContribution,
    required double unitContribution,
    required String contributionYearAndMonth,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _pbService.createEndowmentInsurance(
        cityOfInsuranceParticipation: cityOfInsuranceParticipation,
        unitName: unitName,
        contributionBase: contributionBase,
        personalContribution: personalContribution,
        unitContribution: unitContribution,
        contributionYearAndMonth: contributionYearAndMonth,
      );
      
      if (result != null) {
        // 添加到列表开头
        endowmentInsuranceList.insert(0, result);
        // 重新加载总缴费金额
        loadTotalContributions();
        Get.snackbar('成功', '养老保险记录创建成功');
        return true;
      } else {
        errorMessage.value = '创建养老保险记录失败';
        Get.snackbar('错误', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = '创建养老保险记录时出错: $e';
      Get.snackbar('错误', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 更新养老保险记录
  Future<bool> updateEndowmentInsurance(
    String id, {
    String? cityOfInsuranceParticipation,
    String? unitName,
    double? contributionBase,
    double? personalContribution,
    double? unitContribution,
    String? contributionYearAndMonth,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _pbService.updateEndowmentInsurance(
        id,
        cityOfInsuranceParticipation: cityOfInsuranceParticipation,
        unitName: unitName,
        contributionBase: contributionBase,
        personalContribution: personalContribution,
        unitContribution: unitContribution,
        contributionYearAndMonth: contributionYearAndMonth,
      );
      
      if (result != null) {
        // 更新列表中的记录
        final index = endowmentInsuranceList.indexWhere((item) => item.id == id);
        if (index != -1) {
          endowmentInsuranceList[index] = result;
        }
        // 重新加载总缴费金额
        loadTotalContributions();
        Get.snackbar('成功', '养老保险记录更新成功');
        return true;
      } else {
        errorMessage.value = '更新养老保险记录失败';
        Get.snackbar('错误', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新养老保险记录时出错: $e';
      Get.snackbar('错误', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 删除养老保险记录
  Future<bool> deleteEndowmentInsurance(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final success = await _pbService.deleteEndowmentInsurance(id);
      
      if (success) {
        // 从列表中移除
        endowmentInsuranceList.removeWhere((item) => item.id == id);
        // 重新加载总缴费金额
        loadTotalContributions();
        Get.snackbar('成功', '养老保险记录删除成功');
        return true;
      } else {
        errorMessage.value = '删除养老保险记录失败';
        Get.snackbar('错误', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = '删除养老保险记录时出错: $e';
      Get.snackbar('错误', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 获取总缴费金额（从视图API）
  double get totalContribution {
    return totalPersonalFromApi.value + totalUnitFromApi.value;
  }

  // 获取个人总缴费（从视图API）
  double get totalPersonalContribution {
    return totalPersonalFromApi.value;
  }

  // 获取单位总缴费（从视图API）
  double get totalUnitContribution {
    return totalUnitFromApi.value;
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
  }
}
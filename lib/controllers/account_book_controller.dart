import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../models/account_book_model.dart';

class AccountBookController extends GetxController {
  final PocketBaseService _pbService = Get.find<PocketBaseService>();
  
  final RxList<AccountBookModel> accountBooks = <AccountBookModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;
  
  // 统计数据
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  
  // 当前选择的月份
  final Rx<DateTime> currentMonth = DateTime.now().obs;
  
  int _currentPage = 1;
  final int _perPage = 30;
  String? _currentFilter;
  String? _currentSort;

  @override
  void onInit() {
    super.onInit();
    // 不在这里自动加载数据，让页面控制何时加载
  }

  // 加载记账记录列表
  Future<void> loadAccountBooks({
    bool refresh = false,
    String? filter,
    String? sort,
    int? perPage,
  }) async {
    if (refresh) {
      _currentPage = 1;
      accountBooks.clear();
      hasMore.value = true;
      _currentFilter = filter;
      _currentSort = sort;
    }
    
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _pbService.getAccountBooks(
        page: _currentPage,
        perPage: perPage ?? _perPage,
        filter: _currentFilter ?? filter,
        sort: _currentSort ?? sort,
      );
      
      if (response != null) {
        if (refresh) {
          accountBooks.value = response.items;
        } else {
          accountBooks.addAll(response.items);
        }
        
        hasMore.value = _currentPage < response.totalPages;
        _currentPage++;
        
        // 计算统计数据
        _calculateStatistics();
      } else {
        errorMessage.value = _pbService.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = '加载记账记录失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 创建记账记录
  Future<bool> createAccountBook({
    required double amount,
    String? accountId, // 改为可选参数
    required String categoryId,
    required DateTime accountBookDate,
    String? description,
    String? attachment,
  }) async {
    if (amount == 0) {
      errorMessage.value = '金额不能为0';
      return false;
    }
    
    // 移除账户ID必需验证，允许为空
    
    if (categoryId.trim().isEmpty) {
      errorMessage.value = '请选择分类';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final accountBook = await _pbService.createAccountBook(
        amount: amount,
        accountId: accountId?.trim(), // 允许为null
        categoryId: categoryId.trim(),
        accountBookDate: accountBookDate,
        description: description?.trim(),
        attachment: attachment,
      );
      
      if (accountBook != null) {
        accountBooks.insert(0, accountBook);
        _calculateStatistics();
        Get.snackbar('成功', '记账记录创建成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '创建记账记录失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 更新记账记录
  Future<bool> updateAccountBook(
    String id, {
    double? amount,
    String? accountId,
    String? categoryId,
    DateTime? accountBookDate,
    String? description,
    String? attachment,
  }) async {
    if (amount != null && amount == 0) {
      errorMessage.value = '金额不能为0';
      return false;
    }
    
    if (accountId != null && accountId.trim().isEmpty) {
      errorMessage.value = '请选择账户';
      return false;
    }
    
    if (categoryId != null && categoryId.trim().isEmpty) {
      errorMessage.value = '请选择分类';
      return false;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final updatedAccountBook = await _pbService.updateAccountBook(
        id,
        amount: amount,
        accountId: accountId?.trim(),
        categoryId: categoryId?.trim(),
        accountBookDate: accountBookDate,
        description: description?.trim(),
        attachment: attachment,
      );
      
      if (updatedAccountBook != null) {
        final index = accountBooks.indexWhere((accountBook) => accountBook.id == id);
        if (index != -1) {
          accountBooks[index] = updatedAccountBook;
        }
        _calculateStatistics();
        Get.snackbar('成功', '记账记录更新成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '更新记账记录失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 删除记账记录
  Future<bool> deleteAccountBook(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final success = await _pbService.deleteAccountBook(id);
      
      if (success) {
        accountBooks.removeWhere((accountBook) => accountBook.id == id);
        _calculateStatistics();
        Get.snackbar('成功', '记账记录删除成功');
        return true;
      } else {
        errorMessage.value = _pbService.errorMessage.value;
        return false;
      }
    } catch (e) {
      errorMessage.value = '删除记账记录失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 按账户筛选
  Future<void> filterByAccount(String accountId) async {
    await loadAccountBooks(
      refresh: true,
      filter: 'account_id = "$accountId"',
    );
  }

  // 按分类筛选
  Future<void> filterByCategory(String categoryId) async {
    await loadAccountBooks(
      refresh: true,
      filter: 'category_id = "$categoryId"',
    );
  }

  // 按日期范围筛选
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];
    
    // 使用更大的perPage值确保获取所有记录
    await loadAccountBooks(
      refresh: true,
      filter: 'transaction_date >= "$start" && transaction_date <= "$end"',
      perPage: 200, // 增加每页记录数，确保获取所有数据
    );
    
    // 通知UI更新
    update();
  }

  // 按金额类型筛选（收入/支出）
  Future<void> filterByType(String type) async {
    String filter;
    if (type == '收入') {
      filter = 'amount > 0';
    } else if (type == '支出') {
      filter = 'amount < 0';
    } else {
      filter = '';
    }
    
    await loadAccountBooks(
      refresh: true,
      filter: filter,
    );
  }

  // 按金额排序
  Future<void> sortByAmount({bool ascending = false}) async {
    await loadAccountBooks(
      refresh: true,
      sort: ascending ? '+amount' : '-amount',
    );
  }

  // 按日期排序
  Future<void> sortByDate({bool ascending = false}) async {
    await loadAccountBooks(
      refresh: true,
      sort: ascending ? '+transaction_date' : '-transaction_date',
    );
  }

  // 清除筛选
  Future<void> clearFilter() async {
    await loadAccountBooks(refresh: true);
  }

  // 刷新记账记录列表
  Future<void> refreshAccountBooks() async {
    await loadAccountBooks(refresh: true);
  }

  // 获取指定记账记录
  AccountBookModel? getAccountBookById(String id) {
    try {
      return accountBooks.firstWhere((accountBook) => accountBook.id == id);
    } catch (e) {
      return null;
    }
  }

  // 计算统计数据
  void _calculateStatistics() {
    double income = 0.0;
    double expense = 0.0;
    
    for (final accountBook in accountBooks) {
      if (accountBook.amount > 0) {
        income += accountBook.amount;
      } else {
        expense += accountBook.amount.abs();
      }
    }
    
    totalIncome.value = income;
    totalExpense.value = expense;
    balance.value = income - expense;
  }

  // 获取本月记账记录
  Future<void> loadCurrentMonthAccountBooks() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    print('=== 开始加载本月记账记录 ===');
    print('当前时间: $now');
    print('本月开始: $startOfMonth');
    print('本月结束: $endOfMonth');
    
    await filterByDateRange(startOfMonth, endOfMonth);
  }

  // 获取本年记账记录
  Future<void> loadCurrentYearAccountBooks() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    
    await filterByDateRange(startOfYear, endOfYear);
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
  }

  // 获取总支出
  double getTotalExpense() {
    return totalExpense.value;
  }

  // 获取余额
  double getBalance() {
    return balance.value;
  }

  // 获取总收入
  double getTotalIncome() {
    return totalIncome.value;
  }

  // 切换到上一个月
  Future<void> goToPreviousMonth() async {
    final previousMonth = DateTime(currentMonth.value.year, currentMonth.value.month - 1, 1);
    currentMonth.value = previousMonth;
    await loadSelectedMonthAccountBooks();
  }

  // 切换到下一个月
  Future<void> goToNextMonth() async {
    final nextMonth = DateTime(currentMonth.value.year, currentMonth.value.month + 1, 1);
    currentMonth.value = nextMonth;
    await loadSelectedMonthAccountBooks();
  }

  // 加载选定月份的记账记录
  Future<void> loadSelectedMonthAccountBooks() async {
    final startOfMonth = DateTime(currentMonth.value.year, currentMonth.value.month, 1);
    final endOfMonth = DateTime(currentMonth.value.year, currentMonth.value.month + 1, 0);
    
    await filterByDateRange(startOfMonth, endOfMonth);
  }

  // 获取当前月份的格式化字符串
  String getCurrentMonthString() {
    return '${currentMonth.value.year}-${currentMonth.value.month.toString().padLeft(2, '0')}';
  }
}
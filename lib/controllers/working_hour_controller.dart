import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/working_hour_model.dart';
import '../services/pocketbase_service.dart';

class WorkingHourController extends GetxController {
  final PocketBaseService _pocketBaseService = Get.find<PocketBaseService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var workingHours = <WorkingHourModel>[].obs;
  var totalOvertimeHours = 0.obs;
  var totalOvertimeMinutes = 0.obs;
  var totalWorkingMinutes = 0.obs;
  
  // 当前查看的年月
  var currentYear = DateTime.now().year.obs;
  var currentMonth = DateTime.now().month.obs;
  


  @override
  void onInit() {
    super.onInit();
    fetchWorkingHours();
  }
  
  // 月份切换方法
  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    fetchWorkingHours();
  }
  
  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    fetchWorkingHours();
  }
  
  void goToCurrentMonth() {
    final now = DateTime.now();
    currentYear.value = now.year;
    currentMonth.value = now.month;
    fetchWorkingHours();
  }
  
  // 格式化总加班时长
  String get formattedTotalOvertimeHours {
    final int minutes = totalOvertimeMinutes.value;
    
    // 处理负数工时的情况
    if (minutes < 0) {
      final int absHours = (-minutes) ~/ 60;
      final int absMinutes = (-minutes) % 60;
      
      if (absHours > 0 && absMinutes > 0) {
        return '-$absHours小时$absMinutes分钟';
      } else if (absHours > 0) {
        return '-$absHours小时';
      } else {
        return '-$absMinutes分钟';
      }
    } else if (minutes == 0) {
      return '0分钟';
    }
    
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    
    if (hours > 0 && remainingMinutes > 0) {
      return '$hours小时$remainingMinutes分钟';
    } else if (hours > 0) {
      return '$hours小时';
    } else {
      return '$remainingMinutes分钟';
    }
  }
  
  // 格式化总工时
  String get formattedTotalWorkingHours {
    final int minutes = totalWorkingMinutes.value;
    
    if (minutes == 0) {
      return '0分钟';
    }
    
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    
    if (hours > 0 && remainingMinutes > 0) {
      return '$hours小时$remainingMinutes分钟';
    } else if (hours > 0) {
      return '$hours小时';
    } else {
      return '$remainingMinutes分钟';
    }
  }

  // 添加工时记录
  Future<void> addWorkingHour({
    required DateTime workDate,
    required bool dayShift,
    required int overtimeHours,
    required String allDaysOfTheWeek,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // 检查登录状态
      if (!_pocketBaseService.isLoggedIn) {
        throw Exception('请先登录');
      }
      
      // 构建要提交的数据
      final data = {
        'date': workDate.toIso8601String().split('T')[0], // 只取日期部分
        'day_shift': dayShift,
        'overtime_hours': overtimeHours,
        'all_days_of_the_week': allDaysOfTheWeek,
      };
      
      // 调用API创建记录
      await _pocketBaseService.pb.collection('working_hours').create(body: data);
      
      // 添加成功后刷新数据
      await fetchWorkingHours();
      
      Get.snackbar(
        '成功',
        '工时记录添加成功',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = '添加工时记录失败: $e';
      Get.snackbar(
        '错误',
        '添加工时记录失败: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 获取工时记录
  Future<void> fetchWorkingHours() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // 检查登录状态
      if (!_pocketBaseService.isLoggedIn) {
        // 如果未登录，仍然尝试获取数据，因为这个API可能不需要认证
        // 如果需要认证，会在catch块中处理错误
      }
      
      // 获取指定月份的起始日期和结束日期
      final firstDayOfMonth = DateTime(currentYear.value, currentMonth.value, 1);
      final lastDayOfMonth = DateTime(currentYear.value, currentMonth.value + 1, 0);
      
      // 格式化日期为API查询格式
      final firstDayStr = firstDayOfMonth.toIso8601String().split('T')[0];
      final lastDayStr = lastDayOfMonth.toIso8601String().split('T')[0];
      
      // 构建API查询参数
      final queryParams = {
        'filter': 'date >= "$firstDayStr" && date <= "$lastDayStr"',
        'sort': '-date', // 按日期降序排序
        'perPage': '100', // 每页100条记录
      };
      
      // 调用API获取数据
      final response = await _pocketBaseService.pb.collection('working_hours').getList(
        page: 1,
        perPage: 100,
        filter: queryParams['filter'],
        sort: queryParams['sort'],
      );
      
      // 清空现有数据
      workingHours.clear();
      totalOvertimeMinutes.value = 0;
      totalWorkingMinutes.value = 0;
      
      // 解析并添加新数据
      for (var item in response.items) {
        final workingHour = WorkingHourModel.fromJson(item.toJson());
        workingHours.add(workingHour);
        totalOvertimeMinutes.value += workingHour.overtimeHours;
        totalWorkingMinutes.value += workingHour.dailyWorkingMinutes;
      }
    } catch (e) {
      errorMessage.value = '获取工时记录失败: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
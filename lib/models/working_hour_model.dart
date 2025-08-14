import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:core';

class WorkingHourModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final String date;
  final bool dayShift;
  final int overtimeHours;
  final String allDaysOfTheWeek;
  final String created;
  final String updated;

  WorkingHourModel({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.date,
    required this.dayShift,
    required this.overtimeHours,
    required this.allDaysOfTheWeek,
    required this.created,
    required this.updated,
  });

  factory WorkingHourModel.fromJson(Map<String, dynamic> json) {
    return WorkingHourModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      date: json['date'] ?? '',
      dayShift: json['day_shift'] ?? false,
      overtimeHours: json['overtime_hours'] ?? 0,
      allDaysOfTheWeek: json['all_days_of_the_week'] ?? '',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
    );
  }

  // 格式化创建日期（UTC转北京时间）
  String get formattedCreatedDate {
    try {
      final DateTime utcDateTime = DateTime.parse(created);
      // 转换为北京时间（UTC+8）
      final DateTime beijingDateTime = utcDateTime.add(const Duration(hours: 8));
      return DateFormat('yyyy-MM-dd HH:mm').format(beijingDateTime);
    } catch (e) {
      return created;
    }
  }

  // 格式化更新日期（UTC转北京时间）
  String get formattedUpdatedDate {
    try {
      final DateTime utcDateTime = DateTime.parse(updated);
      // 转换为北京时间（UTC+8）
      final DateTime beijingDateTime = utcDateTime.add(const Duration(hours: 8));
      return DateFormat('yyyy-MM-dd HH:mm').format(beijingDateTime);
    } catch (e) {
      return updated;
    }
  }

  // 格式化工作日期（UTC转北京时间）
  String get formattedWorkDate {
    try {
      if (date.isEmpty) return '';
      final DateTime utcDateTime = DateTime.parse(date);
      // 转换为北京时间（UTC+8）
      final DateTime beijingDateTime = utcDateTime.add(const Duration(hours: 8));
      return DateFormat('yyyy-MM-dd').format(beijingDateTime);
    } catch (e) {
      return date;
    }
  }
  
  // 将加班时长从分钟转为小时和分钟格式
  String get formattedOvertimeHours {
    // 处理负数工时的情况
    if (overtimeHours < 0) {
      final int absHours = (-overtimeHours) ~/ 60;
      final int absMinutes = (-overtimeHours) % 60;
      
      if (absHours > 0 && absMinutes > 0) {
        return '-$absHours小时$absMinutes分钟';
      } else if (absHours > 0) {
        return '-$absHours小时';
      } else {
        return '-$absMinutes分钟';
      }
    } else if (overtimeHours == 0) {
      return '0分钟';
    }
    
    final int hours = overtimeHours ~/ 60;
    final int minutes = overtimeHours % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours小时$minutes分钟';
    } else if (hours > 0) {
      return '$hours小时';
    } else {
      return '$minutes分钟';
    }
  }
  
  // 计算当天工时（分钟）
  int get dailyWorkingMinutes {
    // 若当天加班为负数，则当天工时计算为0
    if (overtimeHours < 0) {
      return 0;
    }
    
    // 使用pocketbase返回的all_days_of_the_week字段判断工作日类型
    bool isWeekendOrHoliday = (allDaysOfTheWeek == '周末' || allDaysOfTheWeek == '节假日');
    
    // 若为正班且加班为正数，则当天工时为480+当天加班时长
    if (!isWeekendOrHoliday) {
      return 480 + overtimeHours; // 480分钟 = 8小时
    }
    
    // 若为周末和节假日，则当天工时为当天加班时长
    return overtimeHours;
  }
  
  // 格式化当天工时
  String get formattedDailyWorkingHours {
    final int minutes = dailyWorkingMinutes;
    
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
  
  // 根据日期获取实际的星期几
  String get actualDayOfWeek {
    try {
      if (date.isEmpty) return '';
      final DateTime workDate = DateTime.parse(date);
      const List<String> weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return weekdays[workDate.weekday - 1];
    } catch (e) {
      return '';
    }
  }
  
  // 获取工作日类型（正班、周末、节假日）
  String get workDayType {
    // 直接使用pocketbase返回的all_days_of_the_week字段
    return allDaysOfTheWeek.isEmpty ? '正班' : allDaysOfTheWeek;
  }
  
  // 获取工作日类型对应的颜色
  Color get workDayTypeColor {
    switch (workDayType) {
      case '周末':
        return Colors.purple.shade700;
      case '节假日':
        return Colors.red.shade700;
      default:
        return Colors.green.shade700;
    }
  }
  
  // 获取工作日类型对应的浅色背景
  Color get workDayTypeBackgroundColor {
    switch (workDayType) {
      case '周末':
        return Colors.purple.shade100;
      case '节假日':
        return Colors.red.shade100;
      default:
        return Colors.green.shade100;
    }
  }
  
  // 获取工作日类型对应的边框颜色
  Color get workDayTypeBorderColor {
    switch (workDayType) {
      case '周末':
        return Colors.purple.shade300;
      case '节假日':
        return Colors.red.shade300;
      default:
        return Colors.green.shade300;
    }
  }
  
  // 获取工作日类型对应的图标
  IconData get workDayTypeIcon {
    switch (workDayType) {
      case '周末':
        return Icons.weekend;
      case '节假日':
        return Icons.celebration;
      default:
        return Icons.work;
    }
  }
}
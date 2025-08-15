import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/working_hour_controller.dart';
import '../models/working_hour_model.dart';

class WorkingHoursReportsPage extends StatefulWidget {
  const WorkingHoursReportsPage({Key? key}) : super(key: key);

  @override
  State<WorkingHoursReportsPage> createState() => _WorkingHoursReportsPageState();
}

class _WorkingHoursReportsPageState extends State<WorkingHoursReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkingHourController controller = Get.find<WorkingHourController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('工时报表'),
        backgroundColor: Colors.blue.shade300,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '月度报表', icon: Icon(Icons.calendar_month)),
            Tab(text: '年度报表', icon: Icon(Icons.calendar_today)),
            Tab(text: '总计报表', icon: Icon(Icons.assessment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyReport(),
          _buildYearlyReport(),
          _buildTotalReport(),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport() {
    return Obx(() {
      final monthlyData = _getMonthlyReportData();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: '本月工时统计',
              icon: Icons.calendar_month,
              color: Colors.blue,
              children: [
                _buildStatItem('总工时', '${monthlyData['totalHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('工作天数', '${monthlyData['workDays'] ?? 0} 天'),
                _buildStatItem('平均每日工时', '${monthlyData['avgHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('加班时长', '${((monthlyData['overtimeHours'] ?? 0) / 60).toStringAsFixed(1)} 小时'),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: '班次分布',
              icon: Icons.schedule,
              color: Colors.green,
              children: [
                ..._buildShiftDistribution(monthlyData['shiftDistribution'] ?? {}),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: '工作日类型分布',
              icon: Icons.work,
              color: Colors.orange,
              children: [
                ..._buildWorkDayTypeDistribution(monthlyData['workDayTypeDistribution'] ?? {}),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildYearlyReport() {
    return Obx(() {
      final yearlyData = _getYearlyReportData();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: '${DateTime.now().year}年工时统计',
              icon: Icons.calendar_today,
              color: Colors.purple,
              children: [
                _buildStatItem('总工时', '${yearlyData['totalHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('工作天数', '${yearlyData['workDays'] ?? 0} 天'),
                _buildStatItem('平均每月工时', '${yearlyData['avgMonthlyHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('总加班时长', '${((yearlyData['overtimeHours'] ?? 0) / 60).toStringAsFixed(1)} 小时'),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: '月度工时趋势',
              icon: Icons.trending_up,
              color: Colors.indigo,
              children: [
                ..._buildMonthlyTrend(yearlyData['monthlyTrend'] ?? {}),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTotalReport() {
    return Obx(() {
      final totalData = _getTotalReportData();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: '总计工时统计',
              icon: Icons.assessment,
              color: Colors.teal,
              children: [
                _buildStatItem('累计总工时', '${totalData['totalHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('累计工作天数', '${totalData['workDays'] ?? 0} 天'),
                _buildStatItem('记录开始日期', totalData['startDate'] ?? '暂无数据'),
                _buildStatItem('最近记录日期', totalData['lastDate'] ?? '暂无数据'),
                _buildStatItem('累计加班时长', '${((totalData['overtimeHours'] ?? 0) / 60).toStringAsFixed(1)} 小时'),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: '整体统计',
              icon: Icons.analytics,
              color: Colors.deepOrange,
              children: [
                _buildStatItem('平均每日工时', '${totalData['avgDailyHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('最高单日工时', '${totalData['maxDailyHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
                _buildStatItem('最低单日工时', '${totalData['minDailyHours']?.toStringAsFixed(1) ?? '0.0'} 小时'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShiftDistribution(Map<String, int> distribution) {
    if (distribution.isEmpty) {
      return [const Text('暂无数据', style: TextStyle(color: Colors.grey))];
    }
    
    return distribution.entries.map((entry) {
      return _buildStatItem('${entry.key}班', '${entry.value} 天');
    }).toList();
  }

  List<Widget> _buildWorkDayTypeDistribution(Map<String, int> distribution) {
    if (distribution.isEmpty) {
      return [const Text('暂无数据', style: TextStyle(color: Colors.grey))];
    }
    
    return distribution.entries.map((entry) {
      return _buildStatItem(entry.key, '${entry.value} 天');
    }).toList();
  }

  List<Widget> _buildMonthlyTrend(Map<int, double> trend) {
    if (trend.isEmpty) {
      return [const Text('暂无数据', style: TextStyle(color: Colors.grey))];
    }
    
    return trend.entries.map((entry) {
      return _buildStatItem('${entry.key}月', '${(entry.value / 60).toStringAsFixed(1)} 小时');
    }).toList();
  }

  Map<String, dynamic> _getMonthlyReportData() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyRecords = controller.workingHours.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.month == currentMonth && recordDate.year == currentYear;
    }).toList();

    if (monthlyRecords.isEmpty) {
      return {
        'totalHours': 0.0,
        'workDays': 0,
        'avgHours': 0.0,
        'overtimeHours': 0.0,
        'shiftDistribution': <String, int>{},
        'workDayTypeDistribution': <String, int>{},
      };
    }

    double totalMinutes = 0.0;
    int overtimeHours = 0;
    Map<String, int> shiftDistribution = {};
    Map<String, int> workDayTypeDistribution = {};

    for (var record in monthlyRecords) {
      totalMinutes += record.dailyWorkingMinutes;
      overtimeHours += record.overtimeHours;
      
      String shiftType = record.dayShift ? '白班' : '夜班';
      shiftDistribution[shiftType] = (shiftDistribution[shiftType] ?? 0) + 1;
      workDayTypeDistribution[record.workDayType] = (workDayTypeDistribution[record.workDayType] ?? 0) + 1;
    }

    return {
      'totalHours': totalMinutes / 60,
      'workDays': monthlyRecords.length,
      'avgHours': (totalMinutes / 60) / monthlyRecords.length,
      'overtimeHours': overtimeHours,
      'shiftDistribution': shiftDistribution,
      'workDayTypeDistribution': workDayTypeDistribution,
    };
  }

  Map<String, dynamic> _getYearlyReportData() {
    final currentYear = DateTime.now().year;
    
    final yearlyRecords = controller.workingHours.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.year == currentYear;
    }).toList();

    if (yearlyRecords.isEmpty) {
      return {
        'totalHours': 0.0,
        'workDays': 0,
        'avgMonthlyHours': 0.0,
        'overtimeHours': 0.0,
        'monthlyTrend': <int, double>{},
      };
    }

    double totalMinutes = 0.0;
    int overtimeHours = 0;
    Map<int, double> monthlyTrend = {};

    for (var record in yearlyRecords) {
      totalMinutes += record.dailyWorkingMinutes;
      overtimeHours += record.overtimeHours;
      
      final month = DateTime.parse(record.date).month;
      monthlyTrend[month] = (monthlyTrend[month] ?? 0.0) + record.dailyWorkingMinutes;
    }

    return {
      'totalHours': totalMinutes / 60,
      'workDays': yearlyRecords.length,
      'avgMonthlyHours': (totalMinutes / 60) / 12,
      'overtimeHours': overtimeHours,
      'monthlyTrend': monthlyTrend,
    };
  }

  Map<String, dynamic> _getTotalReportData() {
    final allRecords = controller.workingHours;

    if (allRecords.isEmpty) {
      return {
        'totalHours': 0.0,
        'workDays': 0,
        'startDate': '暂无数据',
        'lastDate': '暂无数据',
        'overtimeHours': 0.0,
        'avgDailyHours': 0.0,
        'maxDailyHours': 0.0,
        'minDailyHours': 0.0,
      };
    }

    double totalMinutes = 0.0;
    int overtimeHours = 0;
    int maxDailyHours = 0;
    int minDailyHours = 999999;
    
    List<DateTime> dates = [];

    for (var record in allRecords) {
      totalMinutes += record.dailyWorkingMinutes;
      overtimeHours += record.overtimeHours;
      
      if (record.dailyWorkingMinutes > maxDailyHours) {
        maxDailyHours = record.dailyWorkingMinutes;
      }
      if (record.dailyWorkingMinutes < minDailyHours) {
        minDailyHours = record.dailyWorkingMinutes;
      }
      
      dates.add(DateTime.parse(record.date));
    }

    dates.sort();
    
    return {
      'totalHours': totalMinutes / 60,
      'workDays': allRecords.length,
      'startDate': dates.isNotEmpty ? '${dates.first.year}-${dates.first.month.toString().padLeft(2, '0')}-${dates.first.day.toString().padLeft(2, '0')}' : '暂无数据',
      'lastDate': dates.isNotEmpty ? '${dates.last.year}-${dates.last.month.toString().padLeft(2, '0')}-${dates.last.day.toString().padLeft(2, '0')}' : '暂无数据',
      'overtimeHours': overtimeHours,
      'avgDailyHours': (totalMinutes / 60) / allRecords.length,
      'maxDailyHours': maxDailyHours / 60,
       'minDailyHours': minDailyHours == 999999 ? 0.0 : minDailyHours / 60,
    };
  }
}
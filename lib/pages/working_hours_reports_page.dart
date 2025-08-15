import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
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
    // 获取所有历史工时数据用于报表
    controller.fetchAllWorkingHours();
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
      final monthlyData = _getMonthlyChartData();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: '月度工时统计',
              icon: Icons.bar_chart,
              color: Colors.blue,
              children: [
                // 图例
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('正常工时', Colors.green),
                      const SizedBox(width: 20),
                      _buildLegendItem('加班工时', Colors.orange),
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: monthlyData['maxY'],
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String month = monthlyData['months'][groupIndex];
                          double totalHours = rod.toY;
                          double overtimeHours = rod.rodStackItems.isNotEmpty ? 
                            rod.rodStackItems.last.toY - rod.rodStackItems.last.fromY : 0;
                          double normalHours = totalHours - overtimeHours;
                          return BarTooltipItem(
                            '$month\n总工时: ${totalHours.toStringAsFixed(1)}小时\n正常: ${normalHours.toStringAsFixed(1)}小时\n加班: ${overtimeHours.toStringAsFixed(1)}小时',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final months = monthlyData['months'] as List<String>;
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}h',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: monthlyData['barGroups'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildYearlyReport() {
    return Obx(() {
      final yearlyData = _getYearlyChartData();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: '年度工时统计',
              icon: Icons.bar_chart,
              color: Colors.purple,
              children: [
                // 图例
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('正常工时', Colors.green),
                      const SizedBox(width: 20),
                      _buildLegendItem('加班工时', Colors.orange),
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: yearlyData['maxY'],
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.purple,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String year = yearlyData['years'][groupIndex];
                          double totalHours = rod.toY;
                          double overtimeHours = rod.rodStackItems.isNotEmpty ? 
                            rod.rodStackItems.last.toY - rod.rodStackItems.last.fromY : 0;
                          double normalHours = totalHours - overtimeHours;
                          return BarTooltipItem(
                            '$year年\n总工时: ${totalHours.toStringAsFixed(1)}小时\n正常: ${normalHours.toStringAsFixed(1)}小时\n加班: ${overtimeHours.toStringAsFixed(1)}小时',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final years = yearlyData['years'] as List<String>;
                              if (value.toInt() >= 0 && value.toInt() < years.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    years[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}h',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: yearlyData['barGroups'],
                    ),
                  ),
                ),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }



  Map<String, dynamic> _getMonthlyChartData() {
    // 获取所有记录并按月份分组
    Map<String, Map<String, double>> monthlyData = {};
    
    for (var record in controller.allWorkingHours) {
      final recordDate = DateTime.parse(record.date);
      final monthKey = '${recordDate.year}-${recordDate.month.toString().padLeft(2, '0')}';
      
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'normal': 0.0, 'overtime': 0.0};
      }
      
      // 根据工作日类型计算正常工时和加班工时
      bool isWeekendOrHoliday = (record.allDaysOfTheWeek == '周末' || record.allDaysOfTheWeek == '节假日');
      double normalHours = 0.0;
      double overtimeHours = 0.0;
      
      if (record.overtimeHours >= 0) {
        if (isWeekendOrHoliday) {
          // 周末/节假日：正常工时=0，加班工时=overtimeHours
          normalHours = 0.0;
          overtimeHours = record.overtimeHours / 60.0;
        } else {
          // 正班日：正常工时=8小时，加班工时=overtimeHours
          normalHours = 8.0;
          overtimeHours = record.overtimeHours / 60.0;
        }
      }
      // 如果overtimeHours为负数，则该天工时为0（已在dailyWorkingMinutes中处理）
      
      monthlyData[monthKey]!['normal'] = monthlyData[monthKey]!['normal']! + normalHours;
      monthlyData[monthKey]!['overtime'] = monthlyData[monthKey]!['overtime']! + overtimeHours;
    }

    // 按时间排序并取最近12个月
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    final recentEntries = sortedEntries.length > 12 
        ? sortedEntries.sublist(sortedEntries.length - 12)
        : sortedEntries;

    List<String> months = [];
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < recentEntries.length; i++) {
      final entry = recentEntries[i];
      final parts = entry.key.split('-');
      final year = parts[0];
      final month = parts[1];
      final monthName = '${year.substring(2)}年${month}月';
      
      final normalHours = entry.value['normal']!;
      final overtimeHours = entry.value['overtime']!;
      final totalHours = normalHours + overtimeHours;
      
      if (totalHours > maxY) maxY = totalHours;
      
      months.add(monthName);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalHours,
              color: Colors.blue,
              width: 16,
              rodStackItems: [
                BarChartRodStackItem(0, normalHours, Colors.green),
                BarChartRodStackItem(normalHours, totalHours, Colors.orange),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return {
      'months': months,
      'barGroups': barGroups,
      'maxY': maxY * 1.2, // 留出20%的空间
    };
  }

  Map<String, dynamic> _getYearlyChartData() {
    // 获取所有记录并按年份分组
    Map<String, Map<String, double>> yearlyData = {};
    
    for (var record in controller.allWorkingHours) {
      final recordDate = DateTime.parse(record.date);
      final yearKey = recordDate.year.toString();
      
      if (!yearlyData.containsKey(yearKey)) {
        yearlyData[yearKey] = {'normal': 0.0, 'overtime': 0.0};
      }
      
      // 根据工作日类型计算正常工时和加班工时
      bool isWeekendOrHoliday = (record.allDaysOfTheWeek == '周末' || record.allDaysOfTheWeek == '节假日');
      double normalHours = 0.0;
      double overtimeHours = 0.0;
      
      if (record.overtimeHours >= 0) {
        if (isWeekendOrHoliday) {
          // 周末/节假日：正常工时=0，加班工时=overtimeHours
          normalHours = 0.0;
          overtimeHours = record.overtimeHours / 60.0;
        } else {
          // 正班日：正常工时=8小时，加班工时=overtimeHours
          normalHours = 8.0;
          overtimeHours = record.overtimeHours / 60.0;
        }
      }
      // 如果overtimeHours为负数，则该天工时为0（已在dailyWorkingMinutes中处理）
      
      yearlyData[yearKey]!['normal'] = yearlyData[yearKey]!['normal']! + normalHours;
      yearlyData[yearKey]!['overtime'] = yearlyData[yearKey]!['overtime']! + overtimeHours;
    }

    // 按时间排序
    final sortedEntries = yearlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    List<String> years = [];
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final year = entry.key;
      final normalHours = entry.value['normal']!;
      final overtimeHours = entry.value['overtime']!;
      final totalHours = normalHours + overtimeHours;
      
      if (totalHours > maxY) maxY = totalHours;
      
      years.add(year);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalHours,
              color: Colors.purple,
              width: 20,
              rodStackItems: [
                BarChartRodStackItem(0, normalHours, Colors.green),
                BarChartRodStackItem(normalHours, totalHours, Colors.orange),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return {
      'years': years,
      'barGroups': barGroups,
      'maxY': maxY * 1.2, // 留出20%的空间
    };
  }

  Map<String, dynamic> _getTotalReportData() {
    final allRecords = controller.allWorkingHours;

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
    double overtimeMinutes = 0.0;
    int maxDailyHours = 0;
    int minDailyHours = 999999;
    
    List<DateTime> dates = [];

    for (var record in allRecords) {
      totalMinutes += record.dailyWorkingMinutes;
      // 只统计正数的加班时长
      if (record.overtimeHours > 0) {
        overtimeMinutes += record.overtimeHours;
      }
      
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
      'overtimeHours': overtimeMinutes / 60,
      'avgDailyHours': (totalMinutes / 60) / allRecords.length,
      'maxDailyHours': maxDailyHours / 60,
       'minDailyHours': minDailyHours == 999999 ? 0.0 : minDailyHours / 60,
    };
  }
}
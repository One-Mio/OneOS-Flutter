import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/endowment_insurance_controller.dart';

class EndowmentInsuranceReportPage extends StatelessWidget {
  const EndowmentInsuranceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EndowmentInsuranceController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('养老保险报表'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.endowmentInsuranceList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 总体统计卡片
              _buildOverallStatsCard(controller),
              const SizedBox(height: 24),
              
              // 城市统计
              Obx(() => _buildCityStatsCard(controller)),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildOverallStatsCard(EndowmentInsuranceController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '总体统计',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总缴费月数',
                  '${controller.shenzhenMonthsFromApi.value + controller.dongguanMonthsFromApi.value}个月',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '平均月缴费',
                  controller.shenzhenMonthsFromApi.value + controller.dongguanMonthsFromApi.value > 0
                      ? '¥${(controller.totalContribution / (controller.shenzhenMonthsFromApi.value + controller.dongguanMonthsFromApi.value)).toStringAsFixed(2)}'
                      : '¥0.00',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '单位缴费',
                  '¥${controller.totalUnitContribution.toStringAsFixed(2)}',
                  Icons.business,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '个人缴费',
                  '¥${controller.totalPersonalContribution.toStringAsFixed(2)}',
                  Icons.person,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总缴费',
                  '¥${controller.totalContribution.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
  
  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  

  
  Widget _buildCityStatsCard(EndowmentInsuranceController controller) {
    // 使用从API获取的城市缴费月份数
    int shenzhenMonths = controller.shenzhenMonthsFromApi.value;
    int dongguanMonths = controller.dongguanMonthsFromApi.value;
    int totalMonths = shenzhenMonths + dongguanMonths;
    
    // 计算距离在某城市领取养老金还需多少个月（需要120个月即10年）
    int shenzhenNeeded = math.max(0, 120 - shenzhenMonths);
    int dongguanNeeded = math.max(0, 120 - dongguanMonths);
    
    // 计算距离缴满18年还需多少个月（需要216个月）
    int totalNeeded = math.max(0, 216 - totalMonths);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF48BB78).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Color(0xFF48BB78),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '城市统计与养老金资格',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 城市缴费统计（按缴费月数倒序排序）
          ...() {
            // 创建城市数据列表
            List<Map<String, dynamic>> cities = [
              {
                'name': '深圳',
                'months': shenzhenMonths,
                'needed': shenzhenNeeded,
                'color': const Color(0xFF3182CE),
              },
              {
                'name': '东莞',
                'months': dongguanMonths,
                'needed': dongguanNeeded,
                'color': const Color(0xFF38A169),
              },
            ];
            
            // 按缴费月数倒序排序
            cities.sort((a, b) => (b['months'] as int).compareTo(a['months'] as int));
            
            // 生成排序后的城市统计组件列表
            List<Widget> cityWidgets = [];
            for (int i = 0; i < cities.length; i++) {
              final city = cities[i];
              cityWidgets.add(
                _buildCityStatItemWithEligibility(
                  city['name'] as String,
                  city['months'] as int,
                  city['needed'] as int,
                  Icons.location_on,
                  city['color'] as Color,
                ),
              );
              if (i < cities.length - 1) {
                cityWidgets.add(const SizedBox(height: 12));
              }
            }
            
            return cityWidgets;
          }(),
          const SizedBox(height: 16),
          
          // 总缴费月数和18年资格
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF667eea).withValues(alpha: 0.1), const Color(0xFF764ba2).withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF667eea).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总缴费月数',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '深圳 + 东莞',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${totalMonths}个月',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: totalNeeded == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: totalNeeded == 0 ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totalNeeded == 0 ? Icons.check_circle : Icons.schedule,
                        color: totalNeeded == 0 ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '缴满社保18年资格',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              totalNeeded == 0 
                                ? '已满足条件' 
                                : '还需缴费${totalNeeded}个月',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCityStatItemWithEligibility(String city, int months, int neededMonths, IconData icon, Color color) {
    bool canReceivePension = neededMonths == 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '缴费月数',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${months}个月',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: canReceivePension ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: canReceivePension ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  canReceivePension ? Icons.check_circle : Icons.schedule,
                  color: canReceivePension ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '在${city}领取养老金',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        canReceivePension 
                          ? '已满足条件（需缴费满10年）' 
                          : '还需缴费${neededMonths}个月',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  

}
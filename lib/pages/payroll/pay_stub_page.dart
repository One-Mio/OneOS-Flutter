import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pay_stub_controller.dart';
import '../../models/pay_stub_model.dart';
import 'pay_stub_detail_page.dart';

class PayStubPage extends StatelessWidget {
  const PayStubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PayStubController controller = Get.put(PayStubController());
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: _buildAppBar(context, controller, isLargeScreen),
      body: Obx(() {
        if (controller.isLoading.value && controller.payStubs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshPayStubs(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (controller.payStubs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无薪资单数据',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return isLargeScreen 
            ? _buildLargeScreenLayout(controller)
            : _buildMobileLayout(controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, PayStubController controller, bool isLargeScreen) {
    return AppBar(
      title: Text(
        '薪资单',
        style: TextStyle(
          fontSize: isLargeScreen ? 24 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isLargeScreen ? Colors.blue.shade700 : Colors.blue.shade600,
      foregroundColor: Colors.white,
      toolbarHeight: isLargeScreen ? 70 : 56,
      actions: [
        if (isLargeScreen) ...[
          TextButton.icon(
            onPressed: () => controller.refreshPayStubs(),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('刷新数据', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ] else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshPayStubs(),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(PayStubController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshPayStubs,
      child: Column(
        children: [
          // 统计信息卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '总收入',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¥${controller.getTotalIncome().toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '平均收入',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¥${controller.getAverageIncome().toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          '记录数',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.totalItems.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          // 薪资单列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.payStubs.length + (controller.currentPage.value < controller.totalPages.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.payStubs.length) {
                  // 加载更多按钮
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: controller.loadMorePayStubs,
                              child: const Text('加载更多'),
                            ),
                    ),
                  );
                }
                
                final payStub = controller.payStubs[index];
                return _buildPayStubCard(payStub, context, false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout(PayStubController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshPayStubs,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧统计面板
          Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLargeScreenStatsPanel(controller),
                const SizedBox(height: 24),
                _buildQuickActionsPanel(controller),
              ],
            ),
          ),
          // 右侧薪资单列表
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '薪资单记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.payStubs.length + (controller.currentPage.value < controller.totalPages.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.payStubs.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: controller.loadMorePayStubs,
                                      child: const Text('加载更多'),
                                    ),
                            ),
                          );
                        }
                        
                        final payStub = controller.payStubs[index];
                        return _buildPayStubCard(payStub, context, true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenStatsPanel(PayStubController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '薪资统计',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatItem('总收入', '¥${controller.getTotalIncome().toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildStatItem('平均收入', '¥${controller.getAverageIncome().toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          _buildStatItem('记录数', '${controller.totalItems.value}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsPanel(PayStubController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷操作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            icon: Icons.refresh,
            label: '刷新数据',
            onTap: () => controller.refreshPayStubs(),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.analytics,
            label: '薪资分析',
            onTap: () {}, // TODO: 实现薪资分析功能
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.file_download,
            label: '导出数据',
            onTap: () {}, // TODO: 实现导出功能
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayStubCard(PayStubModel payStub, BuildContext context, bool isLargeScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
      elevation: isLargeScreen ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayStubDetailPage(payStub: payStub),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payStub.paymentYearAndMonth,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 12 : 8,
                      vertical: isLargeScreen ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                    ),
                    child: Text(
                      '¥${payStub.netPay.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 16 : 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 12 : 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isLargeScreen ? 18 : 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '发薪日: ${payStub.payday}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isLargeScreen ? 16 : 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLargeScreen ? 16 : 8),
              if (isLargeScreen)
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('基本工资', payStub.basicSalary, isLargeScreen)),
                    Expanded(child: _buildInfoItem('应发工资', payStub.grossPay, isLargeScreen)),
                    Expanded(child: _buildInfoItem('实发工资', payStub.netPay, isLargeScreen)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('基本工资', payStub.basicSalary, isLargeScreen),
                    _buildInfoItem('应发工资', payStub.grossPay, isLargeScreen),
                    _buildInfoItem('实发工资', payStub.netPay, isLargeScreen),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, double value, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isLargeScreen ? 14 : 12,
          ),
        ),
        SizedBox(height: isLargeScreen ? 4 : 2),
        Text(
          '¥${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isLargeScreen ? 16 : 14,
          ),
        ),
      ],
    );
  }

}
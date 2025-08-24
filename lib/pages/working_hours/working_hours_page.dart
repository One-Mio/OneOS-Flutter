import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/working_hour_controller.dart';
import '../../models/working_hour_model.dart';
import 'working_hours_reports_page.dart';

class WorkingHoursPage extends StatelessWidget {
  const WorkingHoursPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 确保控制器已注册
    final WorkingHourController controller = Get.put(WorkingHourController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => controller.previousMonth(),
              tooltip: '上个月',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  '${controller.currentYear}年${controller.currentMonth}月',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => controller.nextMonth(),
              tooltip: '下个月',
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        )),
        backgroundColor: Colors.blue.shade300,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _navigateToReportsPage(),
            tooltip: '工时报表',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorkingHourDialog(controller),
            tooltip: '添加工时',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => controller.goToCurrentMonth(),
            tooltip: '当前月',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  AppBar _buildAppBar(WorkingHourController controller) {
    return AppBar(
      title: const Text('工时记录'),
      backgroundColor: Colors.blue.shade300,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.fetchWorkingHours(),
        ),
      ],
    );
  }

  Widget _buildBody(WorkingHourController controller) {
    return Container(
      color: Colors.grey.shade50,
      child: Obx(() {
          if (controller.isLoading.value && controller.workingHours.isEmpty) {
            return Column(
              children: [
                _buildTotalOvertimePanelSkeleton(),
                Expanded(child: _buildWorkingHoursListSkeleton()),
              ],
            );
          }

          if (controller.errorMessage.value.isNotEmpty && controller.workingHours.isEmpty) {
            return _buildErrorView(controller);
          }

          if (controller.workingHours.isEmpty && !controller.isLoading.value) {
            return _buildEmptyView(controller);
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchWorkingHours(),
            child: Column(
              children: [
                _buildTotalOvertimePanel(controller),
                Expanded(child: _buildWorkingHoursList(controller)),
              ],
            ),
          );
        }),
    );
  }

  Widget _buildTotalOvertimePanelSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSkeletonCard(1),
          const SizedBox(width: 16),
          _buildSkeletonCard(1),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursListSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5, // 显示5个骨架卡片
      itemBuilder: (context, index) {
        return _buildSkeletonCard(0.7 + (index % 3) * 0.1); // 略微不同的动画延迟
      },
    );
  }

  Widget _buildSkeletonCard(double animationDelay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerContainer(60, 20),
              const Spacer(),
              _buildShimmerContainer(80, 20),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerContainer(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmerContainer(200, 16),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(value),
          builder: (context, child) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade300.withOpacity(0.6 + 0.4 * value),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalOvertimePanel(WorkingHourController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // 总加班时长面板 - 左侧
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '本月总加班',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          controller.formattedTotalOvertimeHours,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: controller.totalOvertimeMinutes.value >= 0 
                                ? Colors.blue.shade700 
                                : Colors.red.shade700,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 本月总工时面板 - 右侧
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '本月总工时',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          controller.formattedTotalWorkingHours,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        )),
                      ],
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

  Widget _buildWorkingHoursList(WorkingHourController controller) {
    return Obx(() {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: controller.workingHours.length,
        itemBuilder: (context, index) {
          final workingHour = controller.workingHours[index];
          return _buildWorkingHourCard(workingHour, index);
        },
      );
    });
  }

  Widget _buildErrorView(WorkingHourController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchWorkingHours(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(WorkingHourController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            '本月暂无工时记录',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '工时记录将在这里显示',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.fetchWorkingHours(),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildWorkingHourCard(WorkingHourModel workingHour, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showWorkingHourDetails(workingHour),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workingHour.formattedWorkDate,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workingHour.actualDayOfWeek,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: workingHour.dayShift 
                              ? Colors.blue.shade100 
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: workingHour.dayShift 
                                ? Colors.blue.shade300 
                                : Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              workingHour.dayShift ? Icons.wb_sunny : Icons.nightlight_round,
                              size: 16,
                              color: workingHour.dayShift 
                                  ? Colors.blue.shade700 
                                  : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workingHour.dayShift ? '白班' : '夜班',
                              style: TextStyle(
                                color: workingHour.dayShift 
                                    ? Colors.blue.shade700 
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: workingHour.workDayTypeBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: workingHour.workDayTypeBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                               workingHour.workDayTypeIcon,
                               size: 16,
                               color: workingHour.workDayTypeColor,
                             ),
                             const SizedBox(width: 4),
                             Text(
                               workingHour.workDayType,
                               style: TextStyle(
                                 color: workingHour.workDayTypeColor,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 12,
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: workingHour.overtimeHours >= 0 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: workingHour.overtimeHours >= 0 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      workingHour.overtimeHours >= 0 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                      size: 20,
                      color: workingHour.overtimeHours >= 0 
                          ? Colors.green.shade700 
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '加班时长',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            workingHour.formattedOvertimeHours,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: workingHour.overtimeHours >= 0 
                                  ? Colors.green.shade700 
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '当日工时: ${workingHour.formattedDailyWorkingHours}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '记录于 ${workingHour.formattedCreatedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkingHourDetails(WorkingHourModel workingHour) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    workingHour.dayShift ? Icons.wb_sunny : Icons.nightlight_round,
                    color: workingHour.dayShift ? Colors.orange : Colors.indigo,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '工时详情',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('工作日期', workingHour.formattedWorkDate),
              _buildDetailRow('星期', workingHour.actualDayOfWeek),
              _buildDetailRow('工作日类型', workingHour.workDayType),
              _buildDetailRow('班次', workingHour.dayShift ? '白班' : '夜班'),
              _buildDetailRow('加班时长', workingHour.formattedOvertimeHours),
              _buildDetailRow('当日总工时', workingHour.formattedDailyWorkingHours),
              _buildDetailRow('记录时间', workingHour.formattedCreatedDate),
              _buildDetailRow('更新时间', workingHour.formattedUpdatedDate),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 根据日期获取默认工作日类型的辅助方法
  String _getDefaultWorkDayType(DateTime date) {
    final weekday = date.weekday;
    if (weekday >= 1 && weekday <= 5) {
      return '正班'; // 周一到周五默认正班
    } else {
      return '周末'; // 周六和周日默认周末
    }
  }

  // 构建对话框标题


  void _showAddWorkingHourDialog(WorkingHourController controller) {
    Get.bottomSheet(
      _AddWorkingHourBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _navigateToReportsPage() {
    Get.to(() => const WorkingHoursReportsPage());
  }
}

// 底部弹出对话框组件
class _AddWorkingHourBottomSheet extends StatefulWidget {
  final WorkingHourController controller;

  const _AddWorkingHourBottomSheet({required this.controller});

  @override
  State<_AddWorkingHourBottomSheet> createState() => _AddWorkingHourBottomSheetState();
}

class _AddWorkingHourBottomSheetState extends State<_AddWorkingHourBottomSheet> {
  DateTime selectedDate = DateTime.now();
  bool isDayShift = true;
  String workDayType = '正班';
  final overtimeController = TextEditingController(text: '0');
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    workDayType = _getDefaultWorkDayType(selectedDate);
    dateController = TextEditingController(
      text: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    overtimeController.dispose();
    super.dispose();
  }

  String _getDefaultWorkDayType(DateTime date) {
    final weekday = date.weekday;
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return '周末';
    }
    return '正班';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDateField(),
              const SizedBox(height: 20),
              _buildShiftSelector(),
              const SizedBox(height: 20),
              _buildWorkDayTypeSelector(),
              const SizedBox(height: 20),
              _buildOvertimeInput(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.access_time,
            color: Colors.blue.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            '添加工时记录',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '工作日期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '班次',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildShiftOption('白班', true, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShiftOption('夜班', false, Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftOption(String title, bool isDay, MaterialColor color) {
    final isSelected = isDayShift == isDay;
    return GestureDetector(
      onTap: () {
        setState(() {
          isDayShift = isDay;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color.shade300 : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDay ? Icons.wb_sunny : Icons.nightlight_round,
              color: isSelected ? color.shade700 : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color.shade700 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkDayTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '工作日类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildWorkDayTypeOption('正班', Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildWorkDayTypeOption('周末', Colors.purple),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildWorkDayTypeOption('节假日', Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkDayTypeOption(String type, MaterialColor color) {
    final isSelected = workDayType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          workDayType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color.shade300 : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color.shade700 : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: type == '节假日' ? 13 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOvertimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '加班时长（分钟）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: TextField(
            controller: overtimeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: '输入加班时长（分钟）',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(
                Icons.timer,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _addWorkingHour,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '添加',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        workDayType = _getDefaultWorkDayType(selectedDate);
        dateController.text = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _addWorkingHour() async {
    final overtimeHours = int.tryParse(overtimeController.text) ?? 0;
    Get.back();
    await widget.controller.addWorkingHour(
      workDate: selectedDate,
      dayShift: isDayShift,
      overtimeHours: overtimeHours,
      allDaysOfTheWeek: workDayType,
    );
  }
}

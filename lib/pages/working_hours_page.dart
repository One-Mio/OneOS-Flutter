import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/working_hour_controller.dart';
import '../models/working_hour_model.dart';

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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载工时记录...', style: TextStyle(color: Colors.grey)),
                ],
              ),
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
  Widget _buildDialogHeader() {
    return Row(
      children: [
        Icon(
          Icons.add_circle_outline,
          color: Colors.blue.shade600,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          '添加工时记录',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 构建日期选择字段
  Widget _buildDateField(TextEditingController dateController, DateTime selectedDate, 
      WorkingHourController controller, String allDaysOfTheWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '工作日期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            hintText: '选择工作日期',
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              Get.back();
              _showAddWorkingHourDialog(controller);
            }
          },
        ),
      ],
    );
  }

  // 构建班次选择器
  Widget _buildShiftSelector(bool isDayShift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '班次',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDayShift = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDayShift ? Colors.blue.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: isDayShift ? Colors.blue.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '白班',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDayShift ? Colors.blue.shade700 : Colors.grey.shade600,
                          fontWeight: isDayShift ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDayShift = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: !isDayShift ? Colors.orange.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: !isDayShift ? Colors.orange.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '夜班',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isDayShift ? Colors.orange.shade700 : Colors.grey.shade600,
                          fontWeight: !isDayShift ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 构建工作日类型选择器
  Widget _buildWorkDayTypeSelector(String workDayType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '工作日类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        workDayType = '正班';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: workDayType == '正班' ? Colors.green.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: workDayType == '正班' ? Colors.green.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '正班',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: workDayType == '正班' ? Colors.green.shade700 : Colors.grey.shade600,
                          fontWeight: workDayType == '正班' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        workDayType = '周末';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: workDayType == '周末' ? Colors.purple.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: workDayType == '周末' ? Colors.purple.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '周末',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: workDayType == '周末' ? Colors.purple.shade700 : Colors.grey.shade600,
                          fontWeight: workDayType == '周末' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        workDayType = '节假日';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: workDayType == '节假日' ? Colors.red.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: workDayType == '节假日' ? Colors.red.shade300 : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '节假日',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: workDayType == '节假日' ? Colors.red.shade700 : Colors.grey.shade600,
                          fontWeight: workDayType == '节假日' ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 构建加班时长输入框
  Widget _buildOvertimeInput(TextEditingController controller, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '加班时长（分钟）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: '输入加班时长（分钟）',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 构建对话框按钮
  Widget _buildDialogButtons(WorkingHourController controller, DateTime selectedDate, 
      bool isDayShift, TextEditingController overtimeController, String allDaysOfTheWeek) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              int overtimeHours = int.tryParse(overtimeController.text) ?? 0;
              Get.back();
              await controller.addWorkingHour(
                workDate: selectedDate,
                dayShift: isDayShift,
                overtimeHours: overtimeHours,
                allDaysOfTheWeek: allDaysOfTheWeek,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('添加'),
          ),
        ),
      ],
    );
  }

  void _showAddWorkingHourDialog(WorkingHourController controller) {
    DateTime selectedDate = DateTime.now();
    bool isDayShift = true;
    int overtimeHours = 0;
    String allDaysOfTheWeek = _getDefaultWorkDayType(selectedDate);
    
    final dateController = TextEditingController(
      text: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
    );
    final overtimeController = TextEditingController(text: '0');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogHeader(),
                  const SizedBox(height: 24),
                  _buildDateField(dateController, selectedDate, controller, allDaysOfTheWeek),
                  const SizedBox(height: 16),
                  _buildShiftSelector(isDayShift),
                  const SizedBox(height: 16),
                  _buildWorkDayTypeSelector(allDaysOfTheWeek),
                  const SizedBox(height: 16),
                  _buildOvertimeInput(overtimeController, (value) {
                    overtimeHours = int.tryParse(value) ?? 0;
                  }),
                  const SizedBox(height: 24),
                  _buildDialogButtons(controller, selectedDate, isDayShift, overtimeController, allDaysOfTheWeek),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibration/vibration.dart';
import '../../controllers/account_book_controller.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/account_model.dart';
import '../../models/category_model.dart';

class AddAccountBookPage extends StatefulWidget {
  const AddAccountBookPage({Key? key}) : super(key: key);

  @override
  State<AddAccountBookPage> createState() => _AddAccountBookPageState();
}

class _AddAccountBookPageState extends State<AddAccountBookPage>
    with TickerProviderStateMixin {
  final AccountBookController _accountBookController = Get.find<AccountBookController>();
  final AccountController _accountController = Get.find<AccountController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  
  // 静态变量用于记住上次选择的日期
  static DateTime? _lastSelectedDate;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _amount = '0';
  bool _isExpense = true;
  CategoryModel? _selectedCategory;
  AccountModel? _selectedAccount;
  String _description = '';
  DateTime _selectedDate = _lastSelectedDate ?? DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 初始化动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 启动动画
    _animationController.forward();
    
    // 默认不选择账户
    _selectedAccount = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击其他区域时，让TextField失去焦点
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // 顶部导航栏
                      _buildAppBar(),
                      // 主要内容区域
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // 金额输入卡片
                              _buildAmountCard(),
                            ],
                          ),
                        ),
                      ),
                      // 底部收支类型切换
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: _buildTypeToggle(),
                        ),
                      ),
                    ],
                  ),
              ),
            );
          },
        ),
      ),
    ),
    );
  }

  // 顶部导航栏
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              '记一笔',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 36), // 平衡左侧按钮
        ],
      ),
    );
  }

  // 金额输入卡片
  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isExpense
              ? [
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF8E8E),
                ]
              : [
                  const Color(0xFF4ECDC4),
                  const Color(0xFF44A08D),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isExpense ? '支出金额' : '收入金额',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _amount,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 数字键盘
          _buildNumberPad(),
        ],
      ),
    );
  }

  // 数字键盘
  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNumberButton('.'),
              _buildNumberButton('0'),
              _buildNumberButton('⌫', isDelete: true),
            ],
          ),
          const SizedBox(height: 12),
          // 功能按钮行
          Row(
            children: [
              _buildFunctionButtonInPad(
                '选择分类',
                _selectedCategory?.name ?? '请选择',
                Icons.category_outlined,
                () => _showCategorySelector(),
              ),
              _buildFunctionButtonInPad(
                '账户',
                _selectedAccount?.name ?? '不选择账户',
                Icons.account_balance_wallet_outlined,
                () => _showAccountSelector(),
              ),
              _buildFunctionButtonInPad(
                '日期',
                '${_selectedDate.month}/${_selectedDate.day}',
                Icons.calendar_today_outlined,
                () => _showDatePicker(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 备注和保存按钮行
          Row(
            children: [
              // 添加备注按钮（占2个按钮宽度）
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Vibration.vibrate(duration: 50);
                    _showNoteDialog();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.note_add_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _descriptionController.text.isEmpty ? '添加备注' : _descriptionController.text,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 保存按钮
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Vibration.vibrate(duration: 50);
                    _saveAccountBook();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '保存',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 数字按钮
  Widget _buildNumberButton(String text, {bool isDelete = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNumberTap(text),
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // 数字键盘内的功能按钮
  Widget _buildFunctionButtonInPad(String title, String value, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 添加震动反馈
          Vibration.vibrate(duration: 50);
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 收支类型切换
  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Vibration.vibrate(duration: 50);
                setState(() => _isExpense = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _isExpense
                      ? const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: _isExpense ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '支出',
                      style: TextStyle(
                        color: _isExpense ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Vibration.vibrate(duration: 50);
                setState(() => _isExpense = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: !_isExpense
                      ? const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: !_isExpense ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '收入',
                      style: TextStyle(
                        color: !_isExpense ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 三个功能按钮：分类、账户、日期


  // 显示备注输入对话框
  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.edit_note,
                color: Color(0xFF4ECDC4),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '添加备注',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: '请输入备注信息...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4ECDC4)),
              ),
            ),
            maxLines: 3,
            minLines: 1,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _description = _descriptionController.text;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 数字输入处理
  void _onNumberTap(String number) {
    // 添加震动反馈
    Vibration.vibrate(duration: 50);
    
    setState(() {
      if (number == '⌫') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else if (number == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount == '0') {
          _amount = number;
        } else {
          _amount += number;
        }
      }
    });
  }

  // 显示分类选择器
  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // 顶部拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isExpense
                            ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
                            : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isExpense ? '支出分类' : '收入分类',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
            // 分类网格
            Expanded(
              child: Obx(() {
                final categories = _categoryController.categories
                    .where((category) => category.type == (_isExpense ? '支出' : '收入'))
                    .where((category) => category.ownerId == null || category.ownerId!.isEmpty)
                    .toList();

                if (categories.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无分类',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    
                    // 获取子分类
                    final subCategories = _categoryController.categories
                        .where((c) => c.ownerId == category.id)
                        .toList();

                    return GestureDetector(
                      onTap: () {
                        if (subCategories.isEmpty) {
                          setState(() => _selectedCategory = category);
                          Navigator.pop(context);
                          // 延迟取消焦点，避免备注输入框自动获得焦点
                          Future.delayed(const Duration(milliseconds: 100), () {
                            FocusScope.of(context).unfocus();
                          });
                        } else {
                          _showSubCategorySelector(category, subCategories);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4)).withOpacity(0.2)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4)).withOpacity(0.4)
                                : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: category.icon != null && category.icon!.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: SvgPicture.network(
                                        'http://120.79.186.102:5396/api/files/account_book_categories/${category.id}/${category.icon!}',
                                        colorFilter: ColorFilter.mode(
                                          isSelected ? Colors.white : Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.category,
                                      color: isSelected ? Colors.white : Colors.black,
                                      size: 16,
                                    ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                     fontSize: 10,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.black,
                                   ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 显示子分类选择器
  void _showSubCategorySelector(CategoryModel parentCategory, List<CategoryModel> subCategories) {
    Navigator.pop(context); // 关闭主分类选择器
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // 顶部拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showCategorySelector();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      parentCategory.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 子分类网格
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final category = subCategories[index];
                  final isSelected = _selectedCategory?.id == category.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(context);
                      // 延迟取消焦点，避免备注输入框自动获得焦点
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context).unfocus();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          category.icon != null && category.icon!.isNotEmpty
                              ? SvgPicture.network(
                                  'http://120.79.186.102:5396/api/files/account_book_categories/${category.id}/${category.icon!}',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    isSelected
                                        ? (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4))
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Icon(
                                  Icons.category,
                                  color: isSelected
                                      ? (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4))
                                      : Colors.black,
                                  size: 20,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? (_isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4))
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示账户选择器
  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '选择账户',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // "不选择账户"选项
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.block,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const Text(
                '不选择账户',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '记录时不关联具体账户',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              trailing: _selectedAccount == null
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4FACFE),
                    )
                  : null,
              onTap: () {
                setState(() => _selectedAccount = null);
                Navigator.pop(context);
              },
            ),
            // 账户列表
            ...(_accountController.accounts.map((account) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                account.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '¥${account.initialAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              trailing: _selectedAccount?.id == account.id
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4FACFE),
                    )
                  : null,
              onTap: () {
                setState(() => _selectedAccount = account);
                Navigator.pop(context);
              },
            ))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 显示日期选择器
  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _lastSelectedDate = date; // 保存选择的日期到静态变量
      });
    }
  }

  // 保存记账记录
  void _saveAccountBook() async {
    if (_amount == '0' || _amount.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入金额',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_selectedCategory == null) {
      Get.snackbar(
        '提示',
        '请选择分类',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    // 移除账户必选验证，允许不选择账户
    
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        '提示',
        '请输入有效的金额',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    // 根据收支类型确定金额正负
    final finalAmount = _isExpense ? -amount : amount;
    
    final success = await _accountBookController.createAccountBook(
      amount: finalAmount,
      accountId: _selectedAccount?.id, // 允许为null
      categoryId: _selectedCategory!.id,
      accountBookDate: _selectedDate,
      description: _description.trim().isEmpty ? null : _description.trim(),
    );
    
    if (success) {

      Navigator.of(context).pop();
    }
  }
}
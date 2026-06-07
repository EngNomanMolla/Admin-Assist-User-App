import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/controller/budget_controller.dart';
import 'package:flutter_widgets/controller/expense_controller.dart';
import 'package:flutter_widgets/models/budget_model.dart';
import 'package:flutter_widgets/screens/finance_planner/budget/budget_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BudgetController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BudgetController());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Ensure ExpenseController is initialized for categories
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        controller.fetchActiveBudgets();
      } else {
        controller.fetchCompletedBudgets();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Budget Planner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF97316), // Orange theme
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFFF97316),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBudgetList(context, controller, true),
          _buildBudgetList(context, controller, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, controller),
        backgroundColor: const Color(0xFFF97316), // Orange theme
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, BudgetController controller, bool isActive) {
    return Column(
      children: [
        _buildFilterBar(context, controller, isActive),
        _buildSummaryCard(context, controller, isActive),
        Expanded(
          child: Obx(() {
            final budgets = isActive ? controller.activeBudgets : controller.completedBudgets;
            if (controller.isLoading.value && budgets.isEmpty) {
              return _buildShimmerList();
            }
            if (budgets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_rounded, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      isActive ? 'No active budgets' : 'No completed budgets',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                    ),
                  ],
                ),
              );
            }
            final isLoadingMore = isActive ? controller.isLoadingMoreActive.value : controller.isLoadingMoreHistory.value;
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  if (isActive) {
                    controller.fetchActiveBudgets(isLoadMore: true);
                  } else {
                    controller.fetchCompletedBudgets(isLoadMore: true);
                  }
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
                itemCount: budgets.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == budgets.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                        ),
                      ),
                    );
                  }
                  final budget = budgets[index];
                  return _buildBudgetCard(context, controller, budget);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetController controller, bool isActive) {
    return Obx(() {
      final summary = isActive ? controller.activeSummary.value : controller.historySummary.value;
      final isSummaryLoading = isActive ? controller.isLoadingSummaryActive.value : controller.isLoadingSummaryHistory.value;

      if (isSummaryLoading && summary == null) {
        return _buildSummaryShimmer();
      }

      if (summary == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryItem('Total Budget', summary.totalBudget, const Color(0xFF111827)),
            const Text('-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
            _buildSummaryItem('Total Spent', summary.totalSpent, const Color(0xFFEF4444)),
            const Text('=', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
            _buildSummaryItem('Total Remaining', summary.totalRemaining, const Color(0xFF10B981)),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, double amount, Color amountColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '৳${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: amountColor),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            if (index % 2 == 1) {
              return const Text(
                ' ',
                style: TextStyle(fontSize: 16),
              );
            }
            return Expanded(
              child: Column(
                children: [
                  Container(height: 10, width: 60, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 50, color: Colors.white),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, BudgetController controller, bool isActive) {
    final months = [
      {'name': 'All Months', 'value': null},
      {'name': 'January', 'value': 1},
      {'name': 'February', 'value': 2},
      {'name': 'March', 'value': 3},
      {'name': 'April', 'value': 4},
      {'name': 'May', 'value': 5},
      {'name': 'June', 'value': 6},
      {'name': 'July', 'value': 7},
      {'name': 'August', 'value': 8},
      {'name': 'September', 'value': 9},
      {'name': 'October', 'value': 10},
      {'name': 'November', 'value': 11},
      {'name': 'December', 'value': 12},
    ];

    final currentYear = DateTime.now().year;
    final years = <Map<String, dynamic>>[
      {'name': 'All Years', 'value': null},
    ];
    for (int y = currentYear - 5; y <= currentYear + 10; y++) {
      years.add({'name': y.toString(), 'value': y});
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            // Month Dropdown
            Expanded(
              child: _buildDropdownField<int?>(
                value: isActive ? controller.activeMonth.value : controller.historyMonth.value,
                items: months.map((m) {
                  return DropdownMenuItem<int?>(
                    value: m['value'] as int?,
                    child: Text(
                      m['name'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF111827), fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                hint: 'Month',
                onChanged: (val) {
                  if (isActive) {
                    controller.activeMonth.value = val;
                    controller.fetchActiveBudgets();
                  } else {
                    controller.historyMonth.value = val;
                    controller.fetchCompletedBudgets();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Year Dropdown
            Expanded(
              child: _buildDropdownField<int?>(
                value: isActive ? controller.activeYear.value : controller.historyYear.value,
                items: years.map((y) {
                  return DropdownMenuItem<int?>(
                    value: y['value'] as int?,
                    child: Text(
                      y['name'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF111827), fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                hint: 'Year',
                onChanged: (val) {
                  if (isActive) {
                    controller.activeYear.value = val;
                    controller.fetchActiveBudgets();
                  } else {
                    controller.historyYear.value = val;
                    controller.fetchCompletedBudgets();
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280), size: 18),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          hint: Text(hint, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetController controller, Budget budget) {
    final spend = controller.getSpentAmount(budget);
    final progress = budget.amount > 0 ? spend / budget.amount : 0.0;
    final isOverspent = spend > budget.amount;
    final remaining = budget.amount - spend;
    final overspent = spend - budget.amount;
    final categoryName = controller.getCategoryName(budget.categoryId);

    return GestureDetector(
      onTap: () => Get.to(() => BudgetDetailsScreen(budget: budget)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                        budget.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280), size: 20),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'edit' && budget.status == 'active') {
                      _showUpdateBudgetDialog(context, controller, budget);
                    } else if (val == 'delete') {
                      _showDeleteConfirmation(context, controller, budget.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (budget.status == 'active')
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: Color(0xFF6B7280), size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Budgeted', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    Text('৳${budget.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Spent', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    Text('৳${spend.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isOverspent ? const Color(0xFFEF4444) : const Color(0xFF111827))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(isOverspent ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('dd MMM').format(budget.startDate)} - ${DateFormat('dd MMM').format(budget.endDate)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
                Text(
                  isOverspent ? 'Overspent: ৳${overspent.toStringAsFixed(0)}' : 'Remaining: ৳${remaining.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverspent ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Dialogs

  void _showAddBudgetDialog(BuildContext context, BudgetController controller) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final ExpenseController expenseController = Get.find<ExpenseController>();
    
    String selectedCategory = expenseController.categories.isNotEmpty ? expenseController.categories.first.id : 'all';
    final startDateRx = DateTime.now().obs;
    final endDateRx = DateTime.now().add(const Duration(days: 30)).obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.1), // Orange theme
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_rounded, color: Color(0xFFF97316), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Budget',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => TextField(
                  controller: titleController,
                  enabled: !controller.isLoading.value,
                  decoration: InputDecoration(
                    hintText: 'e.g. Monthly Food',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )),
                const SizedBox(height: 16),
                const Text(
                  'Budget Amount',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => TextField(
                  controller: amountController,
                  enabled: !controller.isLoading.value,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixText: '৳ ',
                    prefixStyle: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                )),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: expenseController.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: controller.isLoading.value ? null : (val) {
                    selectedCategory = val ?? 'all';
                  },
                )),
                const SizedBox(height: 16),
                const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 6),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDateRx.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      startDateRx.value = picked;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 45),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(startDateRx.value), style: const TextStyle(color: Color(0xFF111827))),
                )),
                const SizedBox(height: 16),
                const Text('End Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 6),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDateRx.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      endDateRx.value = picked;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 45),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(endDateRx.value), style: const TextStyle(color: Color(0xFF111827))),
                )),
                const SizedBox(height: 24),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: controller.isLoading.value ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () async {
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        if (titleController.text.isNotEmpty) {
                          final success = await controller.addBudget(
                            title: titleController.text,
                            amount: amount,
                            startDate: startDateRx.value,
                            endDate: endDateRx.value,
                            categoryId: selectedCategory,
                          );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316), // Orange theme
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Add Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateBudgetDialog(BuildContext context, BudgetController controller, Budget budget) {
    final titleController = TextEditingController(text: budget.title);
    final amountController = TextEditingController(text: budget.amount.toString());
    final ExpenseController expenseController = Get.find<ExpenseController>();
    
    String selectedCategory = budget.categoryId;
    final startDateRx = budget.startDate.obs;
    final endDateRx = budget.endDate.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.1), // Orange theme
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: Color(0xFFF97316), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Update Budget',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => TextField(
                  controller: titleController,
                  enabled: !controller.isLoading.value,
                  decoration: InputDecoration(
                    hintText: 'e.g. Monthly Food',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )),
                const SizedBox(height: 16),
                const Text(
                  'Budget Amount',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => TextField(
                  controller: amountController,
                  enabled: !controller.isLoading.value,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixText: '৳ ',
                    prefixStyle: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                )),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: expenseController.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: controller.isLoading.value ? null : (val) {
                    selectedCategory = val ?? 'all';
                  },
                )),
                const SizedBox(height: 16),
                const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 6),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDateRx.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      startDateRx.value = picked;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 45),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(startDateRx.value), style: const TextStyle(color: Color(0xFF111827))),
                )),
                const SizedBox(height: 16),
                const Text('End Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 6),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDateRx.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      endDateRx.value = picked;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(double.infinity, 45),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(endDateRx.value), style: const TextStyle(color: Color(0xFF111827))),
                )),
                const SizedBox(height: 24),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: controller.isLoading.value ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () async {
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        if (titleController.text.isNotEmpty) {
                          final success = await controller.updateBudget(
                            id: budget.id,
                            title: titleController.text,
                            amount: amount,
                            startDate: startDateRx.value,
                            endDate: endDateRx.value,
                            categoryId: selectedCategory,
                          );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316), // Orange theme
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BudgetController controller, String budgetId) {
    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: controller.isLoading.value ? null : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : () async {
              final success = await controller.deleteBudget(budgetId);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      )),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
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
                          Container(
                            width: 140,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 70,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

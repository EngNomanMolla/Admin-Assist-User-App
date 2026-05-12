import 'package:get/get.dart';
import '../models/budget_model.dart';
import 'expense_controller.dart';

class BudgetController extends GetxController {
  var budgets = <Budget>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Add some dummy budgets
    budgets.addAll([
      Budget(
        id: '1',
        title: 'Monthly Food',
        amount: 5000.0,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        categoryId: '1', // Food category ID in ExpenseController
      ),
      Budget(
        id: '2',
        title: 'Transport Budget',
        amount: 2000.0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        categoryId: '2', // Transport category ID in ExpenseController
      ),
      Budget(
        id: '3',
        title: 'Past Food Budget',
        amount: 3000.0,
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        categoryId: '1',
      ),
    ]);
  }

  List<Budget> get activeBudgets => budgets.where((b) => b.endDate.isAfter(DateTime.now())).toList();
  List<Budget> get completedBudgets => budgets.where((b) => b.endDate.isBefore(DateTime.now())).toList();

  void addBudget({
    required String title,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required String categoryId,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    budgets.add(Budget(
      id: id,
      title: title,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
    ));
  }

  void updateBudget({
    required String id,
    required String title,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required String categoryId,
  }) {
    final index = budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      budgets[index] = Budget(
        id: id,
        title: title,
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
      );
    }
  }

  void deleteBudget(String id) {
    budgets.removeWhere((b) => b.id == id);
  }

  // Calculate spent amount dynamically
  double getSpentAmount(Budget budget) {
    // Ensure ExpenseController is initialized
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }
    final ExpenseController expenseController = Get.find<ExpenseController>();
    
    // Find transactions in the same category and within the date range
    final matchingTransactions = expenseController.transactions.where((t) {
      return t.categoryId == budget.categoryId &&
          t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(budget.endDate.add(const Duration(seconds: 1)));
    });

    return matchingTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  String getCategoryName(String categoryId) {
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }
    final ExpenseController expenseController = Get.find<ExpenseController>();
    return expenseController.getCategoryName(categoryId);
  }
}

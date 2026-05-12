import 'package:get/get.dart';
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  var categories = <ExpenseCategory>[].obs;
  var transactions = <ExpenseTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Add some default categories
    categories.addAll([
      ExpenseCategory(id: '1', name: 'Food'),
      ExpenseCategory(id: '2', name: 'Transport'),
      ExpenseCategory(id: '3', name: 'Bills'),
      ExpenseCategory(id: '4', name: 'Entertainment'),
    ]);

    // Add some dummy transactions
    transactions.addAll([
      ExpenseTransaction(id: '1', title: 'Lunch', amount: 150.0, categoryId: '1', date: DateTime.now()),
      ExpenseTransaction(id: '2', title: 'Bus fare', amount: 30.0, categoryId: '2', date: DateTime.now().subtract(const Duration(days: 1))),
      ExpenseTransaction(id: '3', title: 'Internet Bill', amount: 500.0, categoryId: '3', date: DateTime.now().subtract(const Duration(days: 2))),
    ]);
  }

  void addCategory(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    categories.add(ExpenseCategory(id: id, name: name));
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    // Reset categoryId to 'all' for transactions belonging to this category
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].categoryId == id) {
        transactions[i] = ExpenseTransaction(
          id: transactions[i].id,
          title: transactions[i].title,
          amount: transactions[i].amount,
          categoryId: 'all',
          date: transactions[i].date,
        );
      }
    }
  }

  void updateCategory({required String id, required String name}) {
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index] = ExpenseCategory(id: id, name: name);
    }
  }

  void addTransaction({required String title, required double amount, required String categoryId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactions.add(ExpenseTransaction(
      id: id,
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: DateTime.now(),
    ));
  }

  void updateTransaction({required String id, required String title, required double amount, required String categoryId}) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      transactions[index] = ExpenseTransaction(
        id: id,
        title: title,
        amount: amount,
        categoryId: categoryId,
        date: transactions[index].date, // Keep original date
      );
    }
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
  }

  List<ExpenseTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalExpense {
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => ExpenseCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

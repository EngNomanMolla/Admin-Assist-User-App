import 'package:get/get.dart';
import '../models/debt_model.dart';

class DebtController extends GetxController {
  var categories = <DebtCategory>[].obs;
  var transactions = <DebtTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Add some default categories
    categories.addAll([
      DebtCategory(id: '1', name: 'Credit Card'),
      DebtCategory(id: '2', name: 'Personal Loan'),
      DebtCategory(id: '3', name: 'Home Loan'),
    ]);

    // Add some dummy transactions
    transactions.addAll([
      DebtTransaction(id: '1', title: 'EMI', amount: 5000.0, categoryId: '3', date: DateTime.now()),
      DebtTransaction(id: '2', title: 'Friend Loan', amount: 1000.0, categoryId: '2', date: DateTime.now().subtract(const Duration(days: 1))),
    ]);
  }

  void addCategory(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    categories.add(DebtCategory(id: id, name: name));
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    // Reset categoryId to 'all' for transactions belonging to this category
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].categoryId == id) {
        transactions[i] = DebtTransaction(
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
      categories[index] = DebtCategory(id: id, name: name);
    }
  }

  void addTransaction({required String title, required double amount, required String categoryId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactions.add(DebtTransaction(
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
      transactions[index] = DebtTransaction(
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

  List<DebtTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalDebt {
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => DebtCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

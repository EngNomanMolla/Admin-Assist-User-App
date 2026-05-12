import 'package:get/get.dart';
import 'package:flutter_widgets/models/income_model.dart';

class IncomeController extends GetxController {
  final RxList<IncomeCategory> categories = <IncomeCategory>[].obs;
  final RxList<IncomeTransaction> transactions = <IncomeTransaction>[].obs;
  final RxString selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Add some default categories if needed or leave empty
    // categories.add(IncomeCategory(id: '1', name: 'Salary'));
  }

  void addCategory(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    categories.add(IncomeCategory(id: id, name: name));
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    // Reset categoryId to 'all' for transactions belonging to this category
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].categoryId == id) {
        transactions[i] = IncomeTransaction(
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
      categories[index] = IncomeCategory(id: id, name: name);
    }
  }

  void addTransaction({required String title, required double amount, required String categoryId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactions.add(IncomeTransaction(
      id: id,
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: DateTime.now(),
    ));
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
  }

  void updateTransaction({required String id, required String title, required double amount, required String categoryId}) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTx = transactions[index];
      transactions[index] = IncomeTransaction(
        id: id,
        title: title,
        amount: amount,
        categoryId: categoryId,
        date: oldTx.date,
      );
    }
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  List<IncomeTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalIncome {
    return filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Unknown';
  }
}

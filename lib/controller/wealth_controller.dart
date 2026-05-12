import 'package:get/get.dart';
import '../models/wealth_model.dart';

class WealthController extends GetxController {
  var categories = <WealthCategory>[].obs;
  var transactions = <WealthTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Add some default categories
    categories.addAll([
      WealthCategory(id: '1', name: 'Stocks'),
      WealthCategory(id: '2', name: 'Crypto'),
      WealthCategory(id: '3', name: 'Real Estate'),
      WealthCategory(id: '4', name: 'Savings'),
    ]);

    // Add some dummy transactions
    transactions.addAll([
      WealthTransaction(id: '1', title: 'Buy Apple Stock', amount: 12000.0, categoryId: '1', date: DateTime.now()),
      WealthTransaction(id: '2', title: 'Buy Bitcoin', amount: 5000.0, categoryId: '2', date: DateTime.now().subtract(const Duration(days: 1))),
      WealthTransaction(id: '3', title: 'Monthly Savings', amount: 10000.0, categoryId: '4', date: DateTime.now().subtract(const Duration(days: 2))),
    ]);
  }

  void addCategory(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    categories.add(WealthCategory(id: id, name: name));
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    // Reset categoryId to 'all' for transactions belonging to this category
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].categoryId == id) {
        transactions[i] = WealthTransaction(
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
      categories[index] = WealthCategory(id: id, name: name);
    }
  }

  void addTransaction({required String title, required double amount, required String categoryId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactions.add(WealthTransaction(
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
      transactions[index] = WealthTransaction(
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

  List<WealthTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalWealth {
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => WealthCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

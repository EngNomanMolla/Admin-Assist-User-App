import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/provider/expense_provider.dart';
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  final ExpenseProvider _expenseProvider = ExpenseProvider();
  var categories = <ExpenseCategory>[].obs;
  var transactions = <ExpenseTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTransactions();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.getExpenseCategories();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['expense_categories'] != null) {
          if (data['expense_categories'] is Map && data['expense_categories']['data'] != null) {
            list = data['expense_categories']['data'];
          } else if (data['expense_categories'] is List) {
            list = data['expense_categories'];
          }
        } else if (data['categories'] != null) {
          if (data['categories'] is Map && data['categories']['data'] != null) {
            list = data['categories']['data'];
          } else if (data['categories'] is List) {
            list = data['categories'];
          }
        } else if (data['data'] != null) {
          if (data['data'] is Map && data['data']['data'] != null) {
            list = data['data']['data'];
          } else if (data['data'] is List) {
            list = data['data'];
          }
        }

        categories.assignAll(list.map((e) => ExpenseCategory.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching expense categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.getExpenseTransactions();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['expense_transactions'] != null) {
          if (data['expense_transactions'] is Map && data['expense_transactions']['data'] != null) {
            list = data['expense_transactions']['data'];
          } else if (data['expense_transactions'] is List) {
            list = data['expense_transactions'];
          }
        } else if (data['transactions'] != null) {
          if (data['transactions'] is Map && data['transactions']['data'] != null) {
            list = data['transactions']['data'];
          } else if (data['transactions'] is List) {
            list = data['transactions'];
          }
        } else if (data['data'] != null) {
          if (data['data'] is Map && data['data']['data'] != null) {
            list = data['data']['data'];
          } else if (data['data'] is List) {
            list = data['data'];
          }
        }

        transactions.assignAll(list.map((e) => ExpenseTransaction.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching expense transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.createExpenseCategory({'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String categoryId = '';
        if (data != null) {
          if (data['id'] != null) {
            categoryId = data['id'].toString();
          } else if (data['expense_category'] != null && data['expense_category']['id'] != null) {
            categoryId = data['expense_category']['id'].toString();
          } else if (data['category'] != null && data['category']['id'] != null) {
            categoryId = data['category']['id'].toString();
          }
        }
        if (categoryId.isEmpty) {
          categoryId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        categories.add(ExpenseCategory(id: categoryId, name: name));
        Get.snackbar("Success", "Category created successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating expense category: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.deleteExpenseCategory(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
        Get.snackbar("Success", "Category deleted successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting expense category: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCategory({required String id, required String name}) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.updateExpenseCategory(id, {'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          categories[index] = ExpenseCategory(id: id, name: name);
        }
        Get.snackbar("Success", "Category updated successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating expense category: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTransaction({required String title, required double amount, required String categoryId}) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.createExpenseTransaction({
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
        'date': DateTime.now().toIso8601String(),
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String transactionId = '';
        if (data != null) {
          if (data['id'] != null) {
            transactionId = data['id'].toString();
          } else if (data['expense_transaction'] != null && data['expense_transaction']['id'] != null) {
            transactionId = data['expense_transaction']['id'].toString();
          } else if (data['transaction'] != null && data['transaction']['id'] != null) {
            transactionId = data['transaction']['id'].toString();
          }
        }
        if (transactionId.isEmpty) {
          transactionId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        transactions.add(ExpenseTransaction(
          id: transactionId,
          title: title,
          amount: amount,
          categoryId: categoryId,
          date: DateTime.now(),
        ));
        Get.snackbar("Success", "Transaction added successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to add transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating expense transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId}) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.updateExpenseTransaction(id, {
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = transactions.indexWhere((t) => t.id == id);
        if (index != -1) {
          transactions[index] = ExpenseTransaction(
            id: id,
            title: title,
            amount: amount,
            categoryId: categoryId,
            date: transactions[index].date,
          );
        }
        Get.snackbar("Success", "Transaction updated successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating expense transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      final response = await _expenseProvider.deleteExpenseTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transactions.removeWhere((t) => t.id == id);
        Get.snackbar("Success", "Transaction deleted successfully",
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting expense transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
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

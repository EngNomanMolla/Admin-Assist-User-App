import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/provider/expense_provider.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpenseController extends GetxController {
  final ExpenseProvider _expenseProvider = ExpenseProvider();
  var categories = <ExpenseCategory>[].obs;
  var transactions = <ExpenseTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;
  final RxBool isLoading = false.obs;
  int currentPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxDouble serverTotalExpense = 0.0.obs;
  bool _isTransactionsFetching = false;

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

        final fetchedCategories = list.map((e) {
          if (e is Map) {
            return ExpenseCategory.fromMap(Map<String, dynamic>.from(e));
          }
          return ExpenseCategory(id: '', name: '');
        }).where((cat) => cat.id.isNotEmpty).toList();

        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      print("Error fetching expense categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      if (_isTransactionsFetching) return;
      _isTransactionsFetching = true;
      isLoading.value = true;
      currentPage = 1;
      hasMore.value = true;
    }

    try {
      final response = await _expenseProvider.getExpenseTransactions(
        page: currentPage,
        perPage: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['total_expense'] != null) {
          serverTotalExpense.value = double.tryParse(data['total_expense'].toString()) ?? 0.0;
        }
        List<dynamic> list = [];
        bool nextExists = false;

        if (data is Map && data['expense_transactions'] != null) {
          final etData = data['expense_transactions'];
          if (etData is Map) {
            list = etData['data'] ?? [];
            nextExists = etData['next_page_url'] != null;
          } else if (etData is List) {
            list = etData;
          }
        } else if (data is Map && data['data'] != null) {
          final dData = data['data'];
          if (dData is Map) {
            list = dData['data'] ?? [];
            nextExists = dData['next_page_url'] != null;
          } else if (dData is List) {
            list = dData;
          }
        } else if (data is List) {
          list = data;
        }

        final newItems = list.map((e) {
          if (e is Map) {
            return ExpenseTransaction.fromMap(Map<String, dynamic>.from(e));
          }
          return ExpenseTransaction(id: '', title: '', amount: 0.0, categoryId: '', date: DateTime.now());
        }).where((tx) => tx.id.isNotEmpty).toList();

        if (isLoadMore) {
          transactions.addAll(newItems);
        } else {
          transactions.assignAll(newItems);
        }

        hasMore.value = nextExists;
        if (nextExists) {
          currentPage++;
        }
      }
    } catch (e) {
      print("Error fetching expense transactions: $e");
    } finally {
      if (isLoadMore) {
        isLoadingMore.value = false;
      } else {
        _isTransactionsFetching = false;
        isLoading.value = false;
      }
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

  Future<bool> addTransaction({required String title, required double amount, required String categoryId, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _expenseProvider.createExpenseTransaction({
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
        'date': dateStr,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
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

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _expenseProvider.updateExpenseTransaction(id, {
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
        'date': dateStr,
      }
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
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
        await fetchTransactions();
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
    if (selectedCategoryId.value == 'all') {
      return serverTotalExpense.value;
    }
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => ExpenseCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/models/income_model.dart';
import 'package:flutter_widgets/provider/income_provider.dart';

class IncomeController extends GetxController {
  final IncomeProvider _incomeProvider = IncomeProvider();
  final RxList<IncomeCategory> categories = <IncomeCategory>[].obs;
  final RxList<IncomeTransaction> transactions = <IncomeTransaction>[].obs;
  final RxString selectedCategoryId = 'all'.obs;
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
      final response = await _incomeProvider.getIncomeCategories();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['income_categories'] != null) {
          list = data['income_categories'];
        } else if (data['categories'] != null) {
          list = data['categories'];
        }

        categories.assignAll(list.map((e) => IncomeCategory.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching income categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final response = await _incomeProvider.getIncomeTransactions();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['income_transactions'] != null) {
          list = data['income_transactions'];
        } else if (data['transactions'] != null) {
          list = data['transactions'];
        }

        transactions.assignAll(list.map((e) => IncomeTransaction.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching income transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      isLoading.value = true;
      final response = await _incomeProvider.createIncomeCategory({'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String categoryId = '';
        if (data != null) {
          if (data['id'] != null) {
            categoryId = data['id'].toString();
          } else if (data['income_category'] != null && data['income_category']['id'] != null) {
            categoryId = data['income_category']['id'].toString();
          } else if (data['category'] != null && data['category']['id'] != null) {
            categoryId = data['category']['id'].toString();
          }
        }
        if (categoryId.isEmpty) {
          categoryId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        categories.add(IncomeCategory(id: categoryId, name: name));
        Get.snackbar("Success", "Category created successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating income category: $e");
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
      final response = await _incomeProvider.deleteIncomeCategory(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
        Get.snackbar("Success", "Category deleted successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting income category: $e");
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
      final response = await _incomeProvider.updateIncomeCategory(id, {'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          categories[index] = IncomeCategory(id: id, name: name);
        }
        Get.snackbar("Success", "Category updated successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating income category: $e");
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
      final response = await _incomeProvider.createIncomeTransaction({
        'title': title,
        'amount': amount,
        'income_category_id': categoryId,
        'category_id': categoryId,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String transactionId = '';
        if (data != null) {
          if (data['id'] != null) {
            transactionId = data['id'].toString();
          } else if (data['income_transaction'] != null && data['income_transaction']['id'] != null) {
            transactionId = data['income_transaction']['id'].toString();
          } else if (data['transaction'] != null && data['transaction']['id'] != null) {
            transactionId = data['transaction']['id'].toString();
          }
        }
        if (transactionId.isEmpty) {
          transactionId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        transactions.add(IncomeTransaction(
          id: transactionId,
          title: title,
          amount: amount,
          categoryId: categoryId,
          date: DateTime.now(),
        ));
        Get.snackbar("Success", "Transaction created successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating income transaction: $e");
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
      final response = await _incomeProvider.deleteIncomeTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transactions.removeWhere((t) => t.id == id);
        Get.snackbar("Success", "Transaction deleted successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting income transaction: $e");
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
      final response = await _incomeProvider.updateIncomeTransaction(id, {
        'title': title,
        'amount': amount,
        'income_category_id': categoryId,
        'category_id': categoryId,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
        Get.snackbar("Success", "Transaction updated successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating income transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
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

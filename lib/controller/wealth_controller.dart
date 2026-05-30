import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/wealth_model.dart';
import '../provider/wealth_provider.dart';

class WealthController extends GetxController {
  final WealthProvider _wealthProvider = WealthProvider();
  var categories = <WealthCategory>[].obs;
  var transactions = <WealthTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;
  var isLoading = false.obs;
  final RxDouble bankBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTransactions();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.getAssetCategories();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['asset_categories'] != null) {
          list = data['asset_categories'];
        } else if (data['data'] != null) {
          list = data['data'];
        } else if (data['categories'] != null) {
          list = data['categories'];
        }
        final fetchedCategories = list.map((e) => WealthCategory.fromMap(e)).toList();
        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      print("Error fetching asset categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.getAssetTransactions();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['bank_balance'] != null) {
          bankBalance.value = double.tryParse(data['bank_balance'].toString()) ?? 0.0;
        }
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['asset_transactions'] != null) {
          list = data['asset_transactions'];
        } else if (data['data'] != null) {
          list = data['data'];
        } else if (data['transactions'] != null) {
          list = data['transactions'];
        }
        final fetchedTransactions = list.map((e) => WealthTransaction.fromMap(e)).toList();
        transactions.assignAll(fetchedTransactions);
      }
    } catch (e) {
      print("Error fetching asset transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.createAssetCategory({
        'name': name,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> categoryMap = {};
        if (data != null) {
          if (data['asset_category'] != null) {
            categoryMap = data['asset_category'];
          } else if (data['data'] != null) {
            categoryMap = data['data'];
          } else {
            categoryMap = data;
          }
        }
        final newCategory = WealthCategory.fromMap(categoryMap);
        categories.add(newCategory);
        Get.snackbar("Success", "Category created successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating category: $e");
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
      final response = await _wealthProvider.deleteAssetCategory(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
              updates: transactions[i].updates,
            );
          }
        }
        Get.snackbar("Success", "Category deleted successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting category: $e");
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
      final response = await _wealthProvider.updateAssetCategory(id, {
        'name': name,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> categoryMap = {};
        if (data != null) {
          if (data['asset_category'] != null) {
            categoryMap = data['asset_category'];
          } else if (data['data'] != null) {
            categoryMap = data['data'];
          } else {
            categoryMap = data;
          }
        }
        final updated = WealthCategory.fromMap(categoryMap);
        final index = categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          categories[index] = updated;
        }
        Get.snackbar("Success", "Category updated successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating category: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTransaction({required String title, required double amount, required String categoryId, required String notes}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final response = await _wealthProvider.createAssetTransaction({
        'title': title,
        'amount': amount,
        'transaction_date': dateStr,
        'notes': notes,
        'asset_category_id': categoryId,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> transactionMap = {};
        if (data != null) {
          if (data['asset_transaction'] != null) {
            transactionMap = data['asset_transaction'];
          } else if (data['data'] != null) {
            transactionMap = data['data'];
          } else {
            transactionMap = data;
          }
        }
        final newTransaction = WealthTransaction.fromMap(transactionMap);
        transactions.add(newTransaction);
        Get.snackbar("Success", "Asset transaction created successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create asset transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating asset transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId, required String notes}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final response = await _wealthProvider.updateAssetTransaction(id, {
        'title': title,
        'amount': amount,
        'transaction_date': dateStr,
        'notes': notes,
        'asset_category_id': categoryId,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> transactionMap = {};
        if (data != null) {
          if (data['asset_transaction'] != null) {
            transactionMap = data['asset_transaction'];
          } else if (data['data'] != null) {
            transactionMap = data['data'];
          } else {
            transactionMap = data;
          }
        }
        final updatedTransaction = WealthTransaction.fromMap(transactionMap);
        final index = transactions.indexWhere((t) => t.id == id);
        if (index != -1) {
          transactions[index] = updatedTransaction;
        }
        Get.snackbar("Success", "Asset transaction updated successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update asset transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating asset transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void addGotAmount(String transactionId, double amount) {
    final index = transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = transactions[index];
      final updateId = DateTime.now().millisecondsSinceEpoch.toString();
      final newUpdate = WealthUpdate(id: updateId, amount: amount, date: DateTime.now());
      
      final updatedUpdates = List<WealthUpdate>.from(transaction.updates)..add(newUpdate);
      
      transactions[index] = WealthTransaction(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        categoryId: transaction.categoryId,
        date: transaction.date,
        updates: updatedUpdates,
      );
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.deleteAssetTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transactions.removeWhere((t) => t.id == id);
        Get.snackbar("Success", "Asset transaction deleted successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete asset transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting asset transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  List<WealthTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalWealth {
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => WealthCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

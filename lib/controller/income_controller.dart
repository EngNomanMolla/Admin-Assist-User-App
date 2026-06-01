import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/models/income_model.dart';
import 'package:flutter_widgets/provider/income_provider.dart';
import 'package:intl/intl.dart';

class IncomeController extends GetxController {
  final IncomeProvider _incomeProvider = IncomeProvider();
  final RxList<IncomeCategory> categories = <IncomeCategory>[].obs;
  final RxList<IncomeTransaction> transactions = <IncomeTransaction>[].obs;
  final RxString selectedCategoryId = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxDouble bankBalance = 0.0.obs;
  int currentPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxDouble serverTotalIncome = 0.0.obs;
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

        final fetchedCategories = list.map((e) {
          if (e is Map) {
            return IncomeCategory.fromMap(Map<String, dynamic>.from(e));
          }
          return IncomeCategory(id: '', name: '');
        }).where((cat) => cat.id.isNotEmpty).toList();

        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      print("Error fetching income categories: $e");
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
      final response = await _incomeProvider.getIncomeTransactions(
        page: currentPage,
        perPage: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['bank_balance'] != null) {
          bankBalance.value = double.tryParse(data['bank_balance'].toString()) ?? 0.0;
        }
        if (data is Map && data['total_income'] != null) {
          serverTotalIncome.value = double.tryParse(data['total_income'].toString()) ?? 0.0;
        }
        List<dynamic> list = [];
        bool nextExists = false;

        if (data is Map && data['income_transactions'] != null) {
          final itData = data['income_transactions'];
          if (itData is Map) {
            list = itData['data'] ?? [];
            nextExists = itData['next_page_url'] != null;
          } else if (itData is List) {
            list = itData;
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
            return IncomeTransaction.fromMap(Map<String, dynamic>.from(e));
          }
          return IncomeTransaction(id: '', title: '', amount: 0.0, categoryId: '', date: DateTime.now());
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
      print("Error fetching income transactions: $e");
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

  Future<bool> addTransaction({required String title, required double amount, required String categoryId, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _incomeProvider.createIncomeTransaction({
        'title': title,
        'amount': amount,
        'income_category_id': categoryId,
        'category_id': categoryId,
        'date': dateStr,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
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
        await fetchTransactions();
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

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _incomeProvider.updateIncomeTransaction(id, {
        'title': title,
        'amount': amount,
        'income_category_id': categoryId,
        'category_id': categoryId,
        'date': dateStr,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
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
    if (selectedCategoryId.value == 'all') {
      return serverTotalIncome.value;
    }
    return filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    return category?.name ?? 'Unknown';
  }
}

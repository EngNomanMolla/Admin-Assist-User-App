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
  final RxDouble otherAssets = 0.0.obs;
  final RxDouble totalAssets = 0.0.obs;
  int currentPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  bool _isTransactionsFetching = false;
  var historyRecords = <WealthUpdate>[].obs;
  var historySummary = Rxn<Map<String, dynamic>>();
  var isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssetTrackerData();
  }

  Future<void> fetchAssetTrackerData() async {
    isLoading.value = true;
    await fetchCategories();
    await fetchTransactions(isLoadMore: false);
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _wealthProvider.getAssetTrackerData();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> catList = [];
        if (data['categories'] != null) {
          catList = data['categories'];
        }
        final fetchedCategories = catList.map((e) {
          if (e is Map) {
            return WealthCategory.fromMap(Map<String, dynamic>.from(e));
          }
          return WealthCategory(id: '', name: '');
        }).where((cat) => cat.id.isNotEmpty).toList();
        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      print("Error fetching categories: $e");
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
      final response = await _wealthProvider.getAssetTransactions(
        page: currentPage,
        perPage: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse summary
        if (data is Map && data['summary'] != null) {
          bankBalance.value = double.tryParse(data['summary']['bank_balance']?.toString() ?? '0') ?? 0.0;
          otherAssets.value = double.tryParse(data['summary']['other_assets']?.toString() ?? '0') ?? 0.0;
          totalAssets.value = double.tryParse(data['summary']['total_assets']?.toString() ?? '0') ?? 0.0;
        }

        List<dynamic> list = [];
        bool nextExists = false;

        if (data is Map && data['asset_transactions'] != null) {
          final txData = data['asset_transactions'];
          if (txData is Map) {
            list = txData['data'] ?? [];
            nextExists = txData['next_page_url'] != null;
          } else if (txData is List) {
            list = txData;
          }
        } else if (data is Map && data['transactions'] != null) {
          final txData = data['transactions'];
          if (txData is Map) {
            list = txData['data'] ?? [];
            nextExists = txData['next_page_url'] != null;
          } else if (txData is List) {
            list = txData;
          }
        }

        final fetchedTransactions = list.map((e) {
          if (e is Map) {
            return WealthTransaction.fromMap(Map<String, dynamic>.from(e));
          }
          return WealthTransaction(id: '', title: '', amount: 0.0, totalInvested: 0.0, categoryId: '', categoryName: '', date: DateTime.now());
        }).where((tx) => tx.id.isNotEmpty).toList();

        if (isLoadMore) {
          transactions.addAll(fetchedTransactions);
          if (fetchedTransactions.isNotEmpty) {
            currentPage++;
          }
        } else {
          transactions.assignAll(fetchedTransactions);
          currentPage = 2;
        }
        hasMore.value = nextExists;
      }
    } catch (e) {
      print("Error fetching asset transactions: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isTransactionsFetching = false;
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
              totalInvested: transactions[i].totalInvested,
              categoryId: 'all',
              categoryName: 'All',
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

  Future<bool> addTransaction({required String title, required double amount, required String categoryId, required String notes, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _wealthProvider.createAssetTransaction({
        'title': title,
        'amount': amount,
        'date': dateStr,
        'transaction_date': dateStr,
        'notes': notes,
        'asset_category_id': categoryId,
        'category_id': categoryId,
        'bank_balance': bankBalance.value,
        'current_bank_balance': bankBalance.value,
        'current_balance': bankBalance.value,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAssetTrackerData();
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

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId, required String notes, DateTime? customDate}) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(customDate ?? DateTime.now());
      final response = await _wealthProvider.updateAssetTransaction(id, {
        'title': title,
        'amount': amount,
        'date': dateStr,
        'transaction_date': dateStr,
        'notes': notes,
        'asset_category_id': categoryId,
        'category_id': categoryId,
        'bank_balance': bankBalance.value,
        'current_bank_balance': bankBalance.value,
        'current_balance': bankBalance.value,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAssetTrackerData();
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

  Future<bool> addGotAmount(String transactionId, double amount, DateTime date, String notes) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      final response = await _wealthProvider.addGotAmountHistory(transactionId, {
        'type': 'return',
        'amount': amount,
        'transaction_date': dateStr,
        'notes': notes,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAssetTrackerData();
        Get.snackbar("Success", "Asset transaction history added successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to add transaction history",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error adding transaction history: $e");
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
      final response = await _wealthProvider.deleteAssetTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAssetTrackerData();
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
    if (selectedCategoryId.value == 'all') {
      return otherAssets.value;
    }
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => WealthCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }

  Future<void> fetchTransactionHistory(String transactionId) async {
    try {
      isLoadingHistory.value = true;
      final response = await _wealthProvider.getAssetTransactionHistory(transactionId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse transaction_history
        List<dynamic> historyList = [];
        if (data['transaction_history'] != null) {
          historyList = data['transaction_history'];
        } else if (data['asset_transaction'] != null && data['asset_transaction']['records'] != null) {
          historyList = data['asset_transaction']['records'];
        }
        
        final parsedHistory = historyList.map((e) {
          if (e is Map) {
            return WealthUpdate.fromMap(Map<String, dynamic>.from(e));
          }
          return WealthUpdate(id: '', amount: 0.0, date: DateTime.now());
        }).where((h) => h.id.isNotEmpty).toList();
        
        historyRecords.assignAll(parsedHistory);
        
        // Parse summary
        if (data['summary'] != null) {
          historySummary.value = Map<String, dynamic>.from(data['summary']);
        }
      }
    } catch (e) {
      print("Error fetching transaction history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<bool> updateHistoryRecord({
    required String transactionId,
    required String historyId,
    required double amount,
    required String notes,
    required DateTime date,
    required String type,
  }) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      final payload = {
        'amount': amount,
        'notes': notes,
        'transaction_date': dateStr,
        'type': type,
      };

      final response = await _wealthProvider.updateAssetTransactionHistory(transactionId, historyId, payload);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactionHistory(transactionId);
        await fetchAssetTrackerData();
        Get.snackbar("Success", "History record updated successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update history record",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating history record: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteHistoryRecord({
    required String transactionId,
    required String historyId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.deleteAssetTransactionHistory(transactionId, historyId);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactionHistory(transactionId);
        await fetchAssetTrackerData();
        Get.snackbar("Success", "History record deleted successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete history record",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting history record: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> investExtraAmount(String transactionId, double amount, DateTime date, String notes) async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      final response = await _wealthProvider.addGotAmountHistory(transactionId, {
        'type': 'invest',
        'amount': amount,
        'transaction_date': dateStr,
        'notes': notes,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAssetTrackerData();
        Get.snackbar("Success", "Additional investment recorded successfully",
            backgroundColor: const Color(0xFF7B39FD).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to add investment",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error adding investment: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

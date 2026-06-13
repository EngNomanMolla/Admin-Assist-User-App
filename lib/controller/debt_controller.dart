import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/provider/liability_provider.dart';
import '../models/debt_model.dart';
import 'package:intl/intl.dart';

class DebtController extends GetxController {
  final LiabilityProvider _liabilityProvider = LiabilityProvider();
  var categories = <DebtCategory>[].obs;
  var transactions = <DebtTransaction>[].obs;
  var selectedCategoryId = 'all'.obs;
  final RxBool isLoading = false.obs;
  int currentPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxDouble serverTotalDebt = 0.0.obs;
  bool _isTransactionsFetching = false;
  var historyRecords = <DebtPayment>[].obs;
  var historySummary = Rxn<Map<String, dynamic>>();
  var isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTransactions();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.getLiabilityCategories();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['liability_categories'] != null) {
          list = data['liability_categories'];
        } else if (data['categories'] != null) {
          list = data['categories'];
        }

        final fetchedCategories = list.map((e) {
          if (e is Map) {
            return DebtCategory.fromMap(Map<String, dynamic>.from(e));
          }
          return DebtCategory(id: '', name: '');
        }).where((cat) => cat.id.isNotEmpty).toList();

        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      print("Error fetching liability categories: $e");
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
      final response = await _liabilityProvider.getLiabilityTransactions(
        page: currentPage,
        perPage: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['summary'] != null && data['summary']['liability'] != null) {
          serverTotalDebt.value = double.tryParse(data['summary']['liability'].toString()) ?? 0.0;
        }
        List<dynamic> list = [];
        bool nextExists = false;

        if (data is Map && data['liability_transactions'] != null) {
          final ltData = data['liability_transactions'];
          if (ltData is Map) {
            list = ltData['data'] ?? [];
            nextExists = ltData['next_page_url'] != null;
          } else if (ltData is List) {
            list = ltData;
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
            return DebtTransaction.fromMap(Map<String, dynamic>.from(e));
          }
          return DebtTransaction(id: '', title: '', amount: 0.0, categoryId: '', date: DateTime.now());
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
      print("Error fetching liability transactions: $e");
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
      final response = await _liabilityProvider.createLiabilityCategory({'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String categoryId = '';
        if (data != null) {
          if (data['id'] != null) {
            categoryId = data['id'].toString();
          } else if (data['liability_category'] != null && data['liability_category']['id'] != null) {
            categoryId = data['liability_category']['id'].toString();
          } else if (data['category'] != null && data['category']['id'] != null) {
            categoryId = data['category']['id'].toString();
          }
        }
        if (categoryId.isEmpty) {
          categoryId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        categories.add(DebtCategory(id: categoryId, name: name));
        Get.snackbar("Success", "Category created successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating liability category: $e");
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
      final response = await _liabilityProvider.deleteLiabilityCategory(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
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
              payments: transactions[i].payments,
            );
          }
        }
        Get.snackbar("Success", "Category deleted successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting liability category: $e");
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
      final response = await _liabilityProvider.updateLiabilityCategory(id, {'name': name});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          categories[index] = DebtCategory(id: id, name: name);
        }
        Get.snackbar("Success", "Category updated successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update category",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating liability category: $e");
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
      final response = await _liabilityProvider.createLiabilityTransaction({
        'title': title,
        'amount': amount,
        'liability_category_id': categoryId,
        'date': dateStr,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
        Get.snackbar("Success", "Transaction added successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to add transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error adding liability transaction: $e");
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
      final response = await _liabilityProvider.updateLiabilityTransaction(id, {
        'title': title,
        'amount': amount,
        'liability_category_id': categoryId,
        'date': dateStr,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
        Get.snackbar("Success", "Transaction updated successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating liability transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> payDebt(String transactionId, double amount, DateTime date, {String notes = "Repayment of loan"}) async {
    try {
      isLoading.value = true;
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      
      final response = await _liabilityProvider.addLiabilityHistory(transactionId, {
        'type': 'pay',
        'amount': amount,
        'payment_date': formattedDate,
        'notes': notes,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
        Get.snackbar("Success", "Liability paid successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to make payment",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error paying liability: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> takeExtraLiability(String transactionId, double amount, DateTime date, String notes) async {
    try {
      isLoading.value = true;
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      
      final response = await _liabilityProvider.addLiabilityHistory(transactionId, {
        'type': 'borrow',
        'amount': amount,
        'payment_date': formattedDate,
        'notes': notes,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
        Get.snackbar("Success", "Extra liability recorded successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to take extra liability",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error taking extra liability: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentHistory(String transactionId) async {
    try {
      isLoadingHistory.value = true;
      final response = await _liabilityProvider.getLiabilityHistory(transactionId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> historyList = [];
        if (data['payment_history'] != null) {
          historyList = data['payment_history'];
        } else if (data['liability_transaction'] != null && data['liability_transaction']['records'] != null) {
          historyList = data['liability_transaction']['records'];
        }

        final payments = historyList.map((e) => DebtPayment.fromMap(Map<String, dynamic>.from(e))).toList();
        
        historyRecords.assignAll(payments);
        
        if (data['summary'] != null) {
          historySummary.value = Map<String, dynamic>.from(data['summary']);
        }

        final index = transactions.indexWhere((t) => t.id == transactionId);
        if (index != -1) {
          final transaction = transactions[index];
          final double totalAmount = data['summary'] != null
              ? (double.tryParse(data['summary']['total_amount']?.toString() ?? '') ?? transaction.amount)
              : transaction.amount;
              
          transactions[index] = DebtTransaction(
            id: transaction.id,
            title: transaction.title,
            amount: totalAmount,
            categoryId: transaction.categoryId,
            date: transaction.date,
            payments: payments,
          );
        }
      }
    } catch (e) {
      print("Error fetching payment history: $e");
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
        'payment_date': dateStr,
        'type': type,
      };

      final response = await _liabilityProvider.updateLiabilityHistory(transactionId, historyId, payload);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchPaymentHistory(transactionId);
        await fetchTransactions();
        Get.snackbar("Success", "History record updated successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
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
      final response = await _liabilityProvider.deleteLiabilityHistory(transactionId, historyId);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchPaymentHistory(transactionId);
        await fetchTransactions();
        Get.snackbar("Success", "History record deleted successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
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


  Future<bool> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.deleteLiabilityTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchTransactions();
        Get.snackbar("Success", "Transaction deleted successfully",
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete transaction",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting liability transaction: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  List<DebtTransaction> get filteredTransactions {
    if (selectedCategoryId.value == 'all') {
      return transactions;
    }
    return transactions.where((t) => t.categoryId == selectedCategoryId.value).toList();
  }

  double get totalDebt {
    if (selectedCategoryId.value == 'all') {
      return serverTotalDebt.value;
    }
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.remainingAmount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => DebtCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

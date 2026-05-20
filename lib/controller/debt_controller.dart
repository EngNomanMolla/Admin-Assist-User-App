import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/provider/liability_provider.dart';
import '../models/debt_model.dart';

class DebtController extends GetxController {
  final LiabilityProvider _liabilityProvider = LiabilityProvider();
  var categories = <DebtCategory>[].obs;
  var transactions = <DebtTransaction>[].obs;
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

        categories.assignAll(list.map((e) => DebtCategory.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching liability categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.getLiabilityTransactions();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['liability_transactions'] != null) {
          list = data['liability_transactions'];
        } else if (data['transactions'] != null) {
          list = data['transactions'];
        }

        transactions.assignAll(list.map((e) => DebtTransaction.fromMap(e)).toList());
      }
    } catch (e) {
      print("Error fetching liability transactions: $e");
    } finally {
      isLoading.value = false;
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

  Future<bool> addTransaction({required String title, required double amount, required String categoryId}) async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.createLiabilityTransaction({
        'title': title,
        'amount': amount,
        'liability_category_id': categoryId,
        'date': DateTime.now().toIso8601String(),
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        String txId = '';
        if (data != null) {
          if (data['id'] != null) {
            txId = data['id'].toString();
          } else if (data['liability_transaction'] != null && data['liability_transaction']['id'] != null) {
            txId = data['liability_transaction']['id'].toString();
          } else if (data['transaction'] != null && data['transaction']['id'] != null) {
            txId = data['transaction']['id'].toString();
          }
        }
        if (txId.isEmpty) {
          txId = DateTime.now().millisecondsSinceEpoch.toString();
        }
        transactions.add(DebtTransaction(
          id: txId,
          title: title,
          amount: amount,
          categoryId: categoryId,
          date: DateTime.now(),
        ));
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

  Future<bool> updateTransaction({required String id, required String title, required double amount, required String categoryId}) async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.updateLiabilityTransaction(id, {
        'title': title,
        'amount': amount,
        'liability_category_id': categoryId,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = transactions.indexWhere((t) => t.id == id);
        if (index != -1) {
          transactions[index] = DebtTransaction(
            id: id,
            title: title,
            amount: amount,
            categoryId: categoryId,
            date: transactions[index].date,
            payments: transactions[index].payments,
          );
        }
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

  Future<bool> payDebt(String transactionId, double amount) async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final formattedDate = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      
      final response = await _liabilityProvider.addLiabilityPayment(transactionId, {
        'amount': amount,
        'payment_date': formattedDate,
        'status': 'paid',
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final index = transactions.indexWhere((t) => t.id == transactionId);
        if (index != -1) {
          final transaction = transactions[index];
          String paymentId = '';
          if (data != null) {
            if (data['id'] != null) {
              paymentId = data['id'].toString();
            } else if (data['payment'] != null && data['payment']['id'] != null) {
              paymentId = data['payment']['id'].toString();
            }
          }
          if (paymentId.isEmpty) {
            paymentId = DateTime.now().millisecondsSinceEpoch.toString();
          }
          final newPayment = DebtPayment(id: paymentId, amount: amount, date: now);
          final updatedPayments = List<DebtPayment>.from(transaction.payments)..add(newPayment);
          
          transactions[index] = DebtTransaction(
            id: transaction.id,
            title: transaction.title,
            amount: transaction.amount,
            categoryId: transaction.categoryId,
            date: transaction.date,
            payments: updatedPayments,
          );
        }
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

  Future<void> fetchPaymentHistory(String transactionId) async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.getLiabilityPaymentHistory(transactionId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> historyList = [];
        if (data['payment_history'] != null) {
          historyList = data['payment_history'];
        } else if (data['liability_transaction'] != null && data['liability_transaction']['records'] != null) {
          historyList = data['liability_transaction']['records'];
        }

        final payments = historyList.map((e) => DebtPayment.fromMap(e)).toList();
        
        final index = transactions.indexWhere((t) => t.id == transactionId);
        if (index != -1) {
          final transaction = transactions[index];
          transactions[index] = DebtTransaction(
            id: transaction.id,
            title: transaction.title,
            amount: transaction.amount,
            categoryId: transaction.categoryId,
            date: transaction.date,
            payments: payments,
          );
        }
      }
    } catch (e) {
      print("Error fetching payment history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      isLoading.value = true;
      final response = await _liabilityProvider.deleteLiabilityTransaction(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        transactions.removeWhere((t) => t.id == id);
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
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.remainingAmount);
  }

  String getCategoryName(String categoryId) {
    if (categoryId == 'all') return 'All';
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => DebtCategory(id: 'unknown', name: 'Unknown'));
    return category.name;
  }
}

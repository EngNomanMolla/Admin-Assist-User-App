import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../provider/budget_provider.dart';
import 'expense_controller.dart';

class BudgetController extends GetxController {
  final BudgetProvider _budgetProvider = BudgetProvider();
  var budgets = <Budget>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      isLoading.value = true;
      final List<Budget> fetchedList = [];

      // Fetch active budgets
      final activeResponse = await _budgetProvider.getBudgets(status: 'active');
      if (activeResponse.statusCode == 200) {
        final data = jsonDecode(activeResponse.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['budgets'] != null) {
          list = data['budgets'];
        } else if (data['data'] != null) {
          list = data['data'];
        }
        fetchedList.addAll(list.map((e) => Budget.fromMap(e)));
      }

      // Fetch completed/history budgets
      final completedResponse = await _budgetProvider.getBudgets(status: 'completed');
      if (completedResponse.statusCode == 200) {
        final data = jsonDecode(completedResponse.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['budgets'] != null) {
          list = data['budgets'];
        } else if (data['data'] != null) {
          list = data['data'];
        }
        fetchedList.addAll(list.map((e) => Budget.fromMap(e)));
      }

      budgets.assignAll(fetchedList);
    } catch (e) {
      print("Error fetching budgets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Budget> get activeBudgets => budgets.where((b) => b.status == 'active').toList();
  List<Budget> get completedBudgets => budgets.where((b) => b.status != 'active').toList();

  Future<bool> addBudget({
    required String title,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      final startDateStr = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final response = await _budgetProvider.createBudget({
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
        'start_date': startDateStr,
        'end_date': endDateStr,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> budgetMap = {};
        if (data != null) {
          if (data['budget'] != null) {
            budgetMap = data['budget'];
          } else {
            budgetMap = data;
          }
        }
        final newBudget = Budget.fromMap(budgetMap);
        budgets.add(newBudget);
        Get.snackbar("Success", "Budget created successfully",
            backgroundColor: const Color(0xFFF97316).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to create budget",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error creating budget: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBudget({
    required String id,
    required String title,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      final startDateStr = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final response = await _budgetProvider.updateBudget(id, {
        'title': title,
        'amount': amount,
        'expense_category_id': categoryId,
        'start_date': startDateStr,
        'end_date': endDateStr,
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> budgetMap = {};
        if (data != null) {
          if (data['budget'] != null) {
            budgetMap = data['budget'];
          } else {
            budgetMap = data;
          }
        }
        final updated = Budget.fromMap(budgetMap);
        final index = budgets.indexWhere((b) => b.id == id);
        if (index != -1) {
          budgets[index] = updated;
        }
        Get.snackbar("Success", "Budget updated successfully",
            backgroundColor: const Color(0xFFF97316).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to update budget",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error updating budget: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      isLoading.value = true;
      final response = await _budgetProvider.deleteBudget(id);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        budgets.removeWhere((b) => b.id == id);
        Get.snackbar("Success", "Budget deleted successfully",
            backgroundColor: const Color(0xFFF97316).withOpacity(0.9), colorText: Colors.white);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to delete budget",
            backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error deleting budget: $e");
      Get.snackbar("Error", "Network error occurred",
          backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate spent amount from server computed field
  double getSpentAmount(Budget budget) {
    return budget.spent;
  }

  String getCategoryName(String categoryId) {
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }
    final ExpenseController expenseController = Get.find<ExpenseController>();
    return expenseController.getCategoryName(categoryId);
  }
}

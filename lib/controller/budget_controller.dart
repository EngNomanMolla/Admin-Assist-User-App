import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../provider/budget_provider.dart';
import 'expense_controller.dart';

class BudgetController extends GetxController {
  final BudgetProvider _budgetProvider = BudgetProvider();
  var budgets = <Budget>[].obs;
  var activeBudgetsList = <Budget>[].obs;
  var completedBudgetsList = <Budget>[].obs;
  var isLoading = false.obs;

  // Active filters & pagination
  var activeMonth = RxnInt(DateTime.now().month);
  var activeYear = RxnInt(DateTime.now().year);
  var activeCurrentPage = 1;
  var activeHasMore = true.obs;
  var isLoadingMoreActive = false.obs;

  // History filters & pagination
  var historyMonth = RxnInt(DateTime.now().month);
  var historyYear = RxnInt(DateTime.now().year);
  var historyStatus = 'expired'.obs;
  var historyCurrentPage = 1;
  var historyHasMore = true.obs;
  var isLoadingMoreHistory = false.obs;

  bool _isActiveFetching = false;
  bool _isHistoryFetching = false;

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
  }

  Future<void> fetchActiveBudgets({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMoreActive.value || !activeHasMore.value) return;
      isLoadingMoreActive.value = true;
    } else {
      if (_isActiveFetching) return;
      _isActiveFetching = true;
      isLoading.value = true;
      activeCurrentPage = 1;
      activeHasMore.value = true;
      activeBudgetsList.clear();
    }

    try {
      final response = await _budgetProvider.getBudgets(
        status: 'active',
        month: activeMonth.value,
        year: activeYear.value,
        page: activeCurrentPage,
        perPage: 20,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        bool nextExists = false;

        if (data['budgets'] != null) {
          if (data['budgets'] is Map) {
            list = data['budgets']['data'] ?? [];
            nextExists = data['budgets']['next_page_url'] != null;
          } else if (data['budgets'] is List) {
            list = data['budgets'];
          }
        } else if (data['data'] != null) {
          if (data['data'] is List) {
            list = data['data'];
          }
        }

        final newItems = list.map((e) => Budget.fromMap(e)).toList();
        if (isLoadMore) {
          activeBudgetsList.addAll(newItems);
        } else {
          activeBudgetsList.assignAll(newItems);
        }

        activeHasMore.value = nextExists;
        if (nextExists) {
          activeCurrentPage++;
        }
      }
    } catch (e) {
      print("Error fetching active budgets: $e");
    } finally {
      if (isLoadMore) {
        isLoadingMoreActive.value = false;
      } else {
        _isActiveFetching = false;
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchCompletedBudgets({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMoreHistory.value || !historyHasMore.value) return;
      isLoadingMoreHistory.value = true;
    } else {
      if (_isHistoryFetching) return;
      _isHistoryFetching = true;
      isLoading.value = true;
      historyCurrentPage = 1;
      historyHasMore.value = true;
      completedBudgetsList.clear();
    }

    try {
      final response = await _budgetProvider.getBudgets(
        status: historyStatus.value,
        month: historyMonth.value,
        year: historyYear.value,
        page: historyCurrentPage,
        perPage: 20,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        bool nextExists = false;

        if (data['budgets'] != null) {
          if (data['budgets'] is Map) {
            list = data['budgets']['data'] ?? [];
            nextExists = data['budgets']['next_page_url'] != null;
          } else if (data['budgets'] is List) {
            list = data['budgets'];
          }
        } else if (data['data'] != null) {
          if (data['data'] is List) {
            list = data['data'];
          }
        }

        final newItems = list.map((e) => Budget.fromMap(e)).toList();
        if (isLoadMore) {
          completedBudgetsList.addAll(newItems);
        } else {
          completedBudgetsList.assignAll(newItems);
        }

        historyHasMore.value = nextExists;
        if (nextExists) {
          historyCurrentPage++;
        }
      }
    } catch (e) {
      print("Error fetching completed budgets: $e");
    } finally {
      if (isLoadMore) {
        isLoadingMoreHistory.value = false;
      } else {
        _isHistoryFetching = false;
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchBudgets() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchActiveBudgets(),
        fetchCompletedBudgets(),
      ]);
      budgets.assignAll([...activeBudgetsList, ...completedBudgetsList]);
    } catch (e) {
      print("Error fetching budgets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Budget> get activeBudgets => activeBudgetsList;
  List<Budget> get completedBudgets => completedBudgetsList;

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
        fetchBudgets();
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
        fetchBudgets();
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
        fetchBudgets();
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

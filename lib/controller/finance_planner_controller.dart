import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_widgets/provider/wealth_provider.dart';

class FinancePlannerController extends GetxController {
  final WealthProvider _wealthProvider = WealthProvider();
  
  var isLoading = false.obs;
  var income = 0.0.obs;
  var expense = 0.0.obs;
  var netIncome = 0.0.obs;
  var liability = 0.0.obs;
  var totalLiability = 0.0.obs;
  var bankBalance = 0.0.obs;
  var totalAsset = 0.0.obs;
  var netWorth = 0.0.obs;
  var cashflowBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPersonalFinanceHubData();
  }

  Future<void> fetchPersonalFinanceHubData() async {
    try {
      isLoading.value = true;
      final response = await _wealthProvider.getPersonalFinanceHubData();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        income.value = double.tryParse(data['income']?.toString() ?? '0') ?? 0.0;
        expense.value = double.tryParse(data['expense']?.toString() ?? '0') ?? 0.0;
        netIncome.value = double.tryParse(data['total_income']?.toString() ?? '0') ?? 0.0;
        liability.value = double.tryParse(data['liability']?.toString() ?? '0') ?? 0.0;
        totalLiability.value = double.tryParse(data['total_liability']?.toString() ?? '0') ?? 0.0;
        bankBalance.value = double.tryParse(data['bank_balance']?.toString() ?? '0') ?? 0.0;
        totalAsset.value = double.tryParse(data['total_asset']?.toString() ?? '0') ?? 0.0;
        if (data['health'] != null) {
          netWorth.value = double.tryParse(data['health']['net_worth']?.toString() ?? '0') ?? 0.0;
          cashflowBalance.value = double.tryParse(data['health']['cashflow_balance']?.toString() ?? '0') ?? 0.0;
        }
      }
    } catch (e) {
      print("Error fetching personal finance hub data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

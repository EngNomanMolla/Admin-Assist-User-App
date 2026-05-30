import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/screens/finance_planner/income/income_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/expense/expense_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/debt/debt_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/wealth/wealth_screen.dart';
import 'package:flutter_widgets/controller/income_controller.dart';
import 'package:flutter_widgets/controller/expense_controller.dart';
import 'package:flutter_widgets/controller/debt_controller.dart';
import 'package:flutter_widgets/controller/wealth_controller.dart';

class FinancePlannerScreen extends StatelessWidget {
  const FinancePlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final IncomeController incomeController = Get.put(IncomeController());
    final ExpenseController expenseController = Get.put(ExpenseController());
    final DebtController debtController = Get.put(DebtController());
    final WealthController wealthController = Get.put(WealthController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Personal Finance Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage your finances',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // Summary Section 1: Income, Expense, Balance
                Obx(() {
                  final totalIncome = incomeController.totalIncome;
                  final totalExpense = expenseController.totalExpense;
                  final balance = totalIncome - totalExpense;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Income', totalIncome, const Color(0xFF10B981)),
                        const Text('-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                        _buildSummaryItem('Expense', totalExpense, const Color(0xFFEF4444)),
                        const Text('=', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                        _buildSummaryItem('Net Income', balance, const Color(0xFF3B82F6)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Summary Section 2: Liability, Asset
                Obx(() {
                  final netIncome = incomeController.totalIncome - expenseController.totalExpense;
                  final totalLiability = debtController.totalDebt + netIncome;
                  final totalWealth = wealthController.totalWealth;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem('Total Liability', totalLiability, const Color(0xFFF59E0B)),
                        _buildSummaryItem('Total Asset', totalWealth, const Color(0xFF7B39FD)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Summary Section 3: Cash & Bank Balance
                Obx(() {
                  final bankBalance = incomeController.bankBalance.value != 0.0
                      ? incomeController.bankBalance.value
                      : wealthController.bankBalance.value;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cash & Bank Balance',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${bankBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Grid of Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildFinanceCard(
                      title: 'Income',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Get.to(() => const IncomeScreen());
                      },
                    ),
                    _buildFinanceCard(
                      title: 'Expense',
                      icon: Icons.trending_down_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        Get.to(() => const ExpenseScreen());
                      },
                    ),
                    _buildFinanceCard(
                      title: 'Liability', // Renamed from Debt
                      icon: Icons.money_off_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Get.to(() => const DebtScreen());
                      },
                    ),
                    _buildFinanceCard(
                      title: 'Asset', // Renamed from Wealth
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFF7B39FD),
                      onTap: () {
                        Get.to(() => const WealthScreen());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

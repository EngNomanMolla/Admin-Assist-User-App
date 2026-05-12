import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/screens/finance_planner/income/income_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/expense/expense_screen.dart';
import 'package:flutter_widgets/screens/finance_planner/debt/debt_screen.dart';

class FinancePlannerScreen extends StatelessWidget {
  const FinancePlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Finance Planner',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
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
                      title: 'Debt',
                      icon: Icons.money_off_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Get.to(() => const DebtScreen());
                      },
                    ),
                    _buildFinanceCard(
                      title: 'Wealth',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFF7B39FD),
                      onTap: () {
                        Get.snackbar('Wealth', 'Wealth feature coming soon!');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
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

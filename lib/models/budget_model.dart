class Budget {
  final String id;
  final String title;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String categoryId;
  final double spent;
  final double remaining;
  final String status;

  Budget({
    required this.id,
    required this.title,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
    this.spent = 0.0,
    this.remaining = 0.0,
    this.status = 'active',
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    final amt = double.tryParse(map['amount']?.toString() ?? '') ?? 0.0;
    final spt = double.tryParse(map['spent']?.toString() ?? '') ?? 0.0;
    final rem = double.tryParse(map['remaining']?.toString() ?? '') ?? amt;
    return Budget(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      amount: amt,
      startDate: DateTime.tryParse(map['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['end_date']?.toString() ?? '') ?? DateTime.now(),
      categoryId: (map['expense_category_id'] ?? '').toString(),
      spent: spt,
      remaining: rem,
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'start_date': "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date': "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
      'expense_category_id': categoryId,
      'spent': spent,
      'remaining': remaining,
      'status': status,
    };
  }
}

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
  });

  factory BudgetSummary.fromMap(Map<String, dynamic> map) {
    return BudgetSummary(
      totalBudget: double.tryParse(map['total_budget']?.toString() ?? '') ?? 0.0,
      totalSpent: double.tryParse(map['total_spent']?.toString() ?? '') ?? 0.0,
      totalRemaining: double.tryParse(map['total_remaining']?.toString() ?? '') ?? 0.0,
    );
  }

  factory BudgetSummary.empty() {
    return BudgetSummary(totalBudget: 0.0, totalSpent: 0.0, totalRemaining: 0.0);
  }
}

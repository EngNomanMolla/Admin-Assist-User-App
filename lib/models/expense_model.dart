class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});
}

class ExpenseTransaction {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;

  ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
  });
}

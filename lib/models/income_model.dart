class IncomeCategory {
  final String id;
  final String name;

  IncomeCategory({
    required this.id,
    required this.name,
  });
}

class IncomeTransaction {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;

  IncomeTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
  });
}

class DebtCategory {
  final String id;
  final String name;

  DebtCategory({required this.id, required this.name});
}

class DebtTransaction {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;

  DebtTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
  });
}

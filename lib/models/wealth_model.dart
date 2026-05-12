class WealthCategory {
  final String id;
  final String name;

  WealthCategory({required this.id, required this.name});
}

class WealthTransaction {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;

  WealthTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
  });
}

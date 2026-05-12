class Budget {
  final String id;
  final String title;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String categoryId;

  Budget({
    required this.id,
    required this.title,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
  });
}

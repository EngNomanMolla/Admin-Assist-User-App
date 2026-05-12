class WealthCategory {
  final String id;
  final String name;

  WealthCategory({required this.id, required this.name});
}

class WealthUpdate {
  final String id;
  final double amount;
  final DateTime date;

  WealthUpdate({required this.id, required this.amount, required this.date});
}

class WealthTransaction {
  final String id;
  final String title;
  final double amount; // Original amount
  final String categoryId;
  final DateTime date;
  final List<WealthUpdate> updates;

  WealthTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.updates = const [],
  });

  double get totalAmount {
    return amount + updates.fold(0.0, (sum, u) => sum + u.amount);
  }
}

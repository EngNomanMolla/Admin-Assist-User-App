class IncomeCategory {
  final String id;
  final String name;

  IncomeCategory({
    required this.id,
    required this.name,
  });

  factory IncomeCategory.fromMap(Map<String, dynamic> map) {
    return IncomeCategory(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
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

  factory IncomeTransaction.fromMap(Map<String, dynamic> map) {
    return IncomeTransaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['name'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      categoryId: (map['income_category_id'] ?? map['category_id'] ?? map['categoryId'] ?? '').toString(),
      date: DateTime.tryParse(map['date']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'income_category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }
}

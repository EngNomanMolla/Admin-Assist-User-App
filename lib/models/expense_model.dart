class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
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

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['name'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      categoryId: (map['expense_category_id'] ?? map['category_id'] ?? map['categoryId'] ?? '').toString(),
      date: DateTime.tryParse(map['date']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'expense_category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }
}

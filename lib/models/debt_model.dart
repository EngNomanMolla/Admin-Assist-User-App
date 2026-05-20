class DebtCategory {
  final String id;
  final String name;

  DebtCategory({required this.id, required this.name});

  factory DebtCategory.fromMap(Map<String, dynamic> map) {
    return DebtCategory(
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

class DebtPayment {
  final String id;
  final double amount;
  final DateTime date;

  DebtPayment({required this.id, required this.amount, required this.date});

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

class DebtTransaction {
  final String id;
  final String title;
  final double amount; // Original amount
  final String categoryId;
  final DateTime date;
  final List<DebtPayment> payments;

  DebtTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.payments = const [],
  });

  factory DebtTransaction.fromMap(Map<String, dynamic> map) {
    var paymentsList = <DebtPayment>[];
    if (map['payments'] != null) {
      paymentsList = (map['payments'] as List)
          .map((e) => DebtPayment.fromMap(e))
          .toList();
    }
    return DebtTransaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      categoryId: map['liability_category_id']?.toString() ?? map['category_id']?.toString() ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      payments: paymentsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'liability_category_id': categoryId,
      'date': date.toIso8601String(),
      'payments': payments.map((e) => e.toMap()).toList(),
    };
  }

  double get paidAmount {
    return payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    return amount - paidAmount;
  }
}

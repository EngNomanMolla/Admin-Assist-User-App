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
  final String type;
  final String notes;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
    this.type = 'pay',
    this.notes = '',
  });

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    final rawDate = map['payment_date'] ?? map['date'] ?? map['created_at'];
    return DebtPayment(
      id: map['id']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      date: rawDate != null ? DateTime.parse(rawDate.toString()) : DateTime.now(),
      type: map['type']?.toString() ?? 'pay',
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'notes': notes,
    };
  }
}

class DebtTransaction {
  final String id;
  final String title;
  final double amount; // Total / Original amount
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
          .map((e) => DebtPayment.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else if (map['records'] != null) {
      paymentsList = (map['records'] as List)
          .map((e) => DebtPayment.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return DebtTransaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? map['amount']?.toString() ?? '0') ?? 0.0,
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
    return payments.where((p) => p.type == 'pay').fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    return amount - paidAmount;
  }
}

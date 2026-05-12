class DebtCategory {
  final String id;
  final String name;

  DebtCategory({required this.id, required this.name});
}

class DebtPayment {
  final String id;
  final double amount;
  final DateTime date;

  DebtPayment({required this.id, required this.amount, required this.date});
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

  double get paidAmount {
    return payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    return amount - paidAmount;
  }
}

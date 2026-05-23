class PaymentModel {
  final int? id;
  final String name;
  final String mobileNo;
  final String time;
  final String amount;
  final String totalAmount;
  final String status;
  final String repeat;
  final String note;
  final String? nextPaymentDate;
  final List<PaymentRecordModel>? records;

  PaymentModel({
    this.id,
    required this.name,
    required this.mobileNo,
    required this.time,
    required this.amount,
    required this.totalAmount,
    required this.status,
    required this.repeat,
    this.note = "",
    this.nextPaymentDate,
    this.records,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      name: map['client_name'] ?? '',
      mobileNo: map['mobile_no'] ?? '',
      time: map['reminder_date'] ?? '',
      amount: map['due_amount']?.toString() ?? '0',
      totalAmount: map['total_amount']?.toString() ?? '0',
      status: map['status'] ?? 'today',
      repeat: map['repeat'] ?? 'monthly',
      note: map['reminder_text'] ?? '',
      nextPaymentDate: map['next_payment_date'],
      records: map['records'] != null
          ? (map['records'] as List)
              .map((e) => PaymentRecordModel.fromMap(e))
              .toList()
          : null,
    );
  }
}

class PaymentRecordModel {
  final int id;
  final double amount;
  final String date;
  final String status;

  PaymentRecordModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory PaymentRecordModel.fromMap(Map<String, dynamic> map) {
    return PaymentRecordModel(
      id: map['id'],
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      date: map['payment_date'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

class PaymentSummaryModel {
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double progressPercentage;

  PaymentSummaryModel({
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.progressPercentage,
  });

  factory PaymentSummaryModel.fromMap(Map<String, dynamic> map) {
    return PaymentSummaryModel(
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(map['paid_amount']?.toString() ?? '0') ?? 0.0,
      remainingAmount: double.tryParse(map['remaining_amount']?.toString() ?? '0') ?? 0.0,
      progressPercentage: double.tryParse(map['progress_percentage']?.toString() ?? '0') ?? 0.0,
    );
  }
}

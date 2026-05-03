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
    );
  }
}

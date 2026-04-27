class PaymentModel {
  final String name;
  final String mobileNo;
  final String time;
  final String amount;
  final String totalAmount;
  final String status;
  final String repeat;
  final String note;

  PaymentModel({
    required this.name,
    required this.mobileNo,
    required this.time,
    required this.amount,
    required this.totalAmount,
    required this.status,
    required this.repeat,
    this.note = "",
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_widgets/Models/payment_models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentController extends GetxController {
  int selectedTab = 0;

  var paymentList = <PaymentModel>[
    PaymentModel(
      name: "Bipul Sarkar",
      mobileNo: "01710000001",
      time: "25 Jul • 4:00 PM",
      amount: "\$5000",
      totalAmount: "\$8000",
      repeat: "Monthly",
      status: "today",
      note: "Client requested an extension on the next payment. Please follow up on Monday regarding the remaining balance.",
    ),
    PaymentModel(
      name: "Anik Ahmed",
      mobileNo: "01710000002",
      time: "25 Jul • 5:30 PM",
      amount: "\$3000",
      totalAmount: "\$5000",
      repeat: "Weekly",
      status: "today",
    ),
    PaymentModel(
      name: "Sujon Ali",
      mobileNo: "01710000003",
      time: "26 Jul • 10:00 AM",
      amount: "\$1200",
      totalAmount: "\$4000",
      repeat: "Monthly",
      status: "today",
    ),
    PaymentModel(
      name: "Bipul Sarkar",
      mobileNo: "01710000001",
      time: "25 Jul • 7:00 PM",
      amount: "\$4500",
      totalAmount: "\$9000",
      repeat: "Monthly",
      status: "today",
    ),
    PaymentModel(
      name: "Tanvir Hossain",
      mobileNo: "01710000004",
      time: "27 Jul • 12:00 PM",
      amount: "\$8000",
      totalAmount: "\$15000",
      repeat: "Yearly",
      status: "expire",
    ),
  ].obs;

  List<PaymentModel> get filteredList {
    if (selectedTab == 0) {
      return paymentList.where((e) => e.status == "today").toList();
    } else if (selectedTab == 1) {
      return paymentList.where((e) => e.status == "expire").toList();
    } else {
      return paymentList.where((e) => e.status == "next").toList();
    }
  }

  void changeTab(int index) {
    selectedTab = index;
    update();
  }

  void deletePayment(PaymentModel payment) {
    paymentList.remove(payment);
    update();
  }

  final String userName = "John Davis";
  final String paymentType = "Rent Payment";
  final double totalAmount = 2500.0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dueAmountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  
  var selectedRepeat = "Monthly".obs;
  final List<String> repeatOptions = ["Weekly", "Monthly", "Half Yearly", "Yearly"];

  var paymentHistory = <PaymentHistoryModel>[
    PaymentHistoryModel(
      date: "February 1, 2026",
      day: "Sunday",
      amount: 500.0,
      status: "Completed",
    ),
    PaymentHistoryModel(
      date: "January 1, 2026",
      day: "Thursday",
      amount: 500.0,
      status: "Completed",
    ),
    PaymentHistoryModel(
      date: "December 1, 2025",
      day: "Monday",
      amount: 500.0,
      status: "Completed",
    ),
    PaymentHistoryModel(
      date: "November 1, 2025",
      day: "Saturday",
      amount: 450.0,
      status: "Completed",
    ),
  ].obs;

  double get paidAmount =>
      paymentHistory.fold(0, (sum, item) => sum + item.amount);

  double get remainingAmount => totalAmount - paidAmount;

  double get completionPercentage =>
      (totalAmount > 0) ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

  void addHistoryPaymentFromDialog() {
    if (amountController.text.isNotEmpty && dateController.text.isNotEmpty) {
      double enteredAmount = double.tryParse(amountController.text) ?? 0;
      DateTime parsedDate;
      try {
        parsedDate = DateFormat('MMMM d, yyyy').parse(dateController.text);
      } catch (e) {
        parsedDate = DateTime.now();
      }
      String dayName = DateFormat('EEEE').format(parsedDate);

      paymentHistory.insert(
        0,
        PaymentHistoryModel(
          date: dateController.text,
          day: dayName,
          amount: enteredAmount,
          status: "Completed",
        ),
      );

      amountController.clear();
      dateController.clear();
      Get.back();
    }
  }

  void addPaymentReminder() {
    if (nameController.text.isNotEmpty && dueAmountController.text.isNotEmpty) {
      paymentList.insert(
        0,
        PaymentModel(
          name: nameController.text,
          mobileNo: mobileController.text,
          time: dateTimeController.text.isEmpty
              ? DateFormat('d MMM yy • hh:mm a').format(DateTime.now())
              : dateTimeController.text,
          amount: "\$${dueAmountController.text}",
          totalAmount: "\$${totalAmountController.text.isEmpty ? dueAmountController.text : totalAmountController.text}",
          repeat: selectedRepeat.value,
          status: "today",
          note: noteController.text,
        ),
      );

      nameController.clear();
      mobileController.clear();
      dueAmountController.clear();
      totalAmountController.clear();
      dateTimeController.clear();
      noteController.clear();

      Get.back();
      update();
    }
  }
}

class PaymentHistoryModel {
  final String date;
  final String day;
  final double amount;
  final String status;
  PaymentHistoryModel({
    required this.date,
    required this.day,
    required this.amount,
    required this.status,
  });
}

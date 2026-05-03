import 'dart:convert';
import 'package:flutter_widgets/provider/payment_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/Models/payment_models.dart';

class PaymentController extends GetxController {
  final PaymentProvider _paymentProvider = PaymentProvider();
  var isLoading = false.obs;
  DateTime? selectedReminderDate;
  DateTime? selectedInstallmentDate;
  bool isEditing = false;
  int? editingPaymentId;

  var selectedPaymentDetails = Rxn<PaymentModel>();
  var paymentSummary = Rxn<PaymentSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;
      update();
      final response = await _paymentProvider.getPayments();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          paymentList.assignAll(data.map((e) => PaymentModel.fromMap(e)).toList());
        } else if (data['payment_reminders'] != null) {
          paymentList.assignAll((data['payment_reminders'] as List).map((e) => PaymentModel.fromMap(e)).toList());
        }
      }
    } catch (e) {
      print("Error fetching payments: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchPaymentDetails(int id) async {
    try {
      isLoading.value = true;
      selectedPaymentDetails.value = null; // Clear old data
      paymentSummary.value = null;
      update();
      final response = await _paymentProvider.getPaymentDetails(id);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['reminder'] != null) {
          selectedPaymentDetails.value = PaymentModel.fromMap(data['reminder']);
        }
        if (data['summary'] != null) {
          paymentSummary.value = PaymentSummaryModel.fromMap(data['summary']);
        }
      }
    } catch (e) {
      print("Error fetching payment details: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
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

  Future<void> deletePayment(PaymentModel payment) async {
    if (payment.id == null) {
      paymentList.remove(payment);
      update();
      return;
    }

    try {
      isLoading.value = true;
      update();
      final response = await _paymentProvider.deletePayment(payment.id!);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          "Success", 
          "Payment reminder deleted successfully", 
          backgroundColor: const Color(0xFF10B981).withOpacity(0.9), 
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
        fetchPayments();
      } else {
        Get.snackbar("Error", "Failed to delete reminder", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print("Error deleting payment: $e");
      Get.snackbar("Error", "Network error occurred", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void prepareEdit(PaymentModel payment) {
    isEditing = true;
    editingPaymentId = payment.id;
    nameController.text = payment.name;
    mobileController.text = payment.mobileNo;
    dueAmountController.text = payment.amount.replaceAll('\$', '').trim();
    totalAmountController.text = payment.totalAmount.replaceAll('', '').trim();
    noteController.text = payment.note;
    
    try {
      selectedReminderDate = DateTime.parse(payment.time);
      dateTimeController.text = DateFormat('d MMM yy • hh:mm a').format(selectedReminderDate!);
    } catch (e) {
      dateTimeController.text = payment.time;
      selectedReminderDate = null;
    }
    
    String? matched = repeatOptions.firstWhereOrNull((e) => e.toLowerCase() == payment.repeat.toLowerCase());
    if (matched != null) selectedRepeat.value = matched;
    
    update();
  }

  void prepareCreate() {
    isEditing = false;
    editingPaymentId = null;
    nameController.clear();
    mobileController.clear();
    dueAmountController.clear();
    totalAmountController.clear();
    dateTimeController.clear();
    noteController.clear();
    selectedReminderDate = null;
    selectedRepeat.value = "Monthly";
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

  Future<void> addInstallmentPayment(int reminderId) async {
    if (amountController.text.isNotEmpty) {
      try {
        isLoading.value = true;
        update();

        Map<String, dynamic> body = {
          "amount": double.tryParse(amountController.text) ?? 0,
          "payment_date": selectedInstallmentDate != null 
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedInstallmentDate!)
              : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          "status": "paid"
        };

        final response = await _paymentProvider.addPayment(reminderId, body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Get.back();
          Get.snackbar(
            "Success", 
            "Payment added successfully", 
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), 
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
          fetchPayments(); 
          amountController.clear();
          dateController.clear();
          selectedInstallmentDate = null;
        } else {
          final errorData = jsonDecode(response.body);
          Get.snackbar("Error", errorData['message'] ?? "Failed to add payment", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        }
      } catch (e) {
        print("Error adding installment: $e");
        Get.snackbar("Error", "Network error occurred", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }

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

  Future<void> savePaymentReminder() async {
    if (nameController.text.isNotEmpty && dueAmountController.text.isNotEmpty) {
      try {
        isLoading.value = true;
        update();

        Map<String, dynamic> body = {
          "client_name": nameController.text,
          "mobile_no": mobileController.text,
          "due_amount": double.tryParse(dueAmountController.text) ?? 0,
          "total_amount": double.tryParse(totalAmountController.text) ?? 0,
          "reminder_text": noteController.text,
          "reminder_date": selectedReminderDate != null 
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedReminderDate!)
              : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          "repeat": selectedRepeat.value.toLowerCase(),
          "status": "nextup", 
          "notification_enabled": true,
          "notify_before_minutes": 30,
          "notification_title": "Payment due soon",
          "notification_body": "Collect monthly installment from ${nameController.text}.",
          "next_payment_date": DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30))),
        };

        final response = isEditing 
            ? await _paymentProvider.updatePayment(editingPaymentId!, body)
            : await _paymentProvider.createPayment(body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Get.back();
          Get.snackbar(
            "Success", 
            isEditing ? "Reminder updated successfully" : "Reminder created successfully", 
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9), 
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
          
          fetchPayments(); 

          nameController.clear();
          mobileController.clear();
          dueAmountController.clear();
          totalAmountController.clear();
          dateTimeController.clear();
          noteController.clear();
          selectedReminderDate = null;
          isEditing = false;
          editingPaymentId = null;
        } else {
          final errorData = jsonDecode(response.body);
          Get.snackbar("Error", errorData['message'] ?? "Failed to save reminder", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        }
      } catch (e) {
        print("Error saving payment: $e");
        Get.snackbar("Error", "Network error occurred", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> reschedulePayment(PaymentModel payment, DateTime newDate) async {
    try {
      isLoading.value = true;
      update();

      Map<String, dynamic> body = {
        "client_name": payment.name,
        "mobile_no": payment.mobileNo,
        "due_amount": double.tryParse(payment.amount.replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0,
        "total_amount": double.tryParse(payment.totalAmount.replaceAll('\$', '').replaceAll(',', '').trim()) ?? 0,
        "reminder_text": payment.note,
        "reminder_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate),
        "repeat": payment.repeat.toLowerCase(),
        "status": "nextup", 
        "notification_enabled": true,
        "notify_before_minutes": 30,
        "notification_title": "Payment due soon",
        "notification_body": "Collect monthly installment from ${payment.name}.",
        "next_payment_date": DateFormat('yyyy-MM-dd').format(newDate.add(const Duration(days: 30))),
      };

      final response = await _paymentProvider.updatePayment(payment.id!, body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          "Success", 
          "Payment rescheduled successfully", 
          backgroundColor: const Color(0xFF10B981).withOpacity(0.9), 
          colorText: Colors.white,
          icon: const Icon(Icons.event_available_rounded, color: Colors.white),
        );
        fetchPayments();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to reschedule", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print("Error rescheduling: $e");
      Get.snackbar("Error", "Network error occurred", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
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

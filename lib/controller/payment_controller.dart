import 'dart:convert';
import 'package:flutter_widgets/provider/payment_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/Models/payment_models.dart';
import 'package:flutter_widgets/services/notification_service.dart';

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
    NotificationService().requestPermissions();
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

        // Schedule notifications for all fetched payments
        for (var payment in paymentList) {
          if (payment.id != null) {
            double due = double.tryParse(payment.amount) ?? 0;
            if (due == 0 || payment.status == "complete") {
              // Cancel notifications if they exist
              await NotificationService().cancelNotification(payment.id!);
              await NotificationService().cancelNotification(payment.id! + 100000);
              continue; // Skip scheduling
            }
            try {
              DateTime dueDate = DateTime.parse(payment.time);
              String repeatKey = payment.repeat.toLowerCase();
              
              if (repeatKey != 'once' && payment.nextPaymentDate != null) {
                // Schedule one-time notification for the rescheduled current date
                await NotificationService().scheduleTaskNotification(
                  payment.id!,
                  "Payment Reminder: ${payment.name}",
                  payment.note.isNotEmpty ? payment.note : "You have a payment reminder.",
                  dueDate,
                  repeat: 'once',
                );

                // Schedule the repeating notification starting on the next_payment_date
                DateTime nextRepeatDate = DateTime.parse(payment.nextPaymentDate!);
                await NotificationService().scheduleTaskNotification(
                  payment.id! + 100000,
                  "Payment Reminder (Repeat): ${payment.name}",
                  payment.note.isNotEmpty ? payment.note : "You have a payment reminder.",
                  nextRepeatDate,
                  repeat: repeatKey,
                );
              } else {
                await NotificationService().scheduleTaskNotification(
                  payment.id!,
                  "Payment Reminder: ${payment.name}",
                  payment.note.isNotEmpty ? payment.note : "You have a payment reminder.",
                  dueDate,
                  repeat: repeatKey,
                );
                await NotificationService().cancelNotification(payment.id! + 100000);
              }
            } catch (e) {
              print("Error scheduling notification for payment ${payment.id}: $e");
            }
          }
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
  var paymentList = <PaymentModel>[].obs;
  var paymentHistory = <PaymentHistoryModel>[].obs;

  List<PaymentModel> get filteredList {
    if (selectedTab == 0) {
      return paymentList.where((e) => e.status == "today" && (double.tryParse(e.amount) ?? 0) > 0).toList();
    } else if (selectedTab == 1) {
      return paymentList.where((e) => e.status == "expire" && (double.tryParse(e.amount) ?? 0) > 0).toList();
    } else if (selectedTab == 2) {
      return paymentList.where((e) => e.status == "nextup" && (double.tryParse(e.amount) ?? 0) > 0).toList();
    } else {
      return paymentList.where((e) => e.status == "complete" || (double.tryParse(e.amount) ?? 0) == 0).toList();
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
        // Cancel local notifications
        await NotificationService().cancelNotification(payment.id!);
        await NotificationService().cancelNotification(payment.id! + 100000);

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
    
    String? label = repeatKeyToLabel[payment.repeat.toLowerCase()];
    if (label != null) selectedRepeat.value = label;
    
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
    selectedRepeat.value = "Once";
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
  
  var selectedRepeat = "Once".obs;
  final List<String> repeatOptions = [
    "Once",
    "Daily",
    "Weekly",
    "Month",
    "Half-Year",
    "Year"
  ];
  
  final Map<String, String> repeatKeyToLabel = {
    "once": "Once",
    "daily": "Daily",
    "weekly": "Weekly",
    "monthly": "Month",
    "half_yearly": "Half-Year",
    "yearly": "Year",
  };

  final Map<String, String> repeatLabelToKey = {
    "Once": "once",
    "Daily": "daily",
    "Weekly": "weekly",
    "Month": "monthly",
    "Half-Year": "half_yearly",
    "Year": "yearly",
  };

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

        final reminderDate = selectedReminderDate ?? DateTime.now();
        final repeatKey = repeatLabelToKey[selectedRepeat.value] ?? "once";
        final nextPayDate = _calculateNextPaymentDate(
          baseDate: reminderDate,
          repeatKey: repeatKey,
          limitDate: reminderDate,
        );

        Map<String, dynamic> body = {
          "client_name": nameController.text,
          "mobile_no": mobileController.text,
          "due_amount": double.tryParse(dueAmountController.text) ?? 0,
          "total_amount": double.tryParse(totalAmountController.text) ?? 0,
          "reminder_text": noteController.text,
          "reminder_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(reminderDate),
          "repeat": repeatKey,
          "status": "nextup", 
          "notification_enabled": true,
          "notify_before_minutes": 30,
          "notification_title": "Payment due soon",
          "notification_body": "Collect monthly installment from ${nameController.text}.",
          "next_payment_date": nextPayDate,
        };

        final response = isEditing 
            ? await _paymentProvider.updatePayment(editingPaymentId!, body)
            : await _paymentProvider.createPayment(body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          int paymentId = isEditing ? editingPaymentId! : 0;
          
          try {
            final resData = jsonDecode(response.body);
            if (resData['reminder'] != null && resData['reminder']['id'] != null) {
              paymentId = int.tryParse(resData['reminder']['id'].toString()) ?? paymentId;
            } else if (resData['id'] != null) {
              paymentId = int.tryParse(resData['id'].toString()) ?? paymentId;
            }
          } catch (e) {
            print("Error parsing payment ID: $e");
          }

          // Cancel any existing notifications for this ID so fetchPayments can reschedule fresh
          if (paymentId != 0) {
            await NotificationService().cancelNotification(paymentId);
            await NotificationService().cancelNotification(paymentId + 100000);
          }

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

      DateTime originalDate = DateTime.tryParse(payment.time) ?? DateTime.now();
      final nextPayDate = _calculateNextPaymentDate(
        baseDate: originalDate,
        repeatKey: payment.repeat,
        limitDate: newDate,
      );

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
        "next_payment_date": nextPayDate,
      };

      final response = await _paymentProvider.updatePayment(payment.id!, body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (payment.id != null) {
          await NotificationService().cancelNotification(payment.id!);
          await NotificationService().cancelNotification(payment.id! + 100000);
        }

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

  String _calculateNextPaymentDate({
    required DateTime baseDate,
    required String repeatKey,
    required DateTime limitDate,
  }) {
    DateTime nextDate = baseDate;
    final rKey = repeatKey.toLowerCase().replaceAll('-', '_');
    
    if (rKey == 'once') {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(baseDate);
    }
    
    while (nextDate.isBefore(limitDate) || nextDate.isAtSameMomentAs(limitDate)) {
      if (rKey == 'daily') {
        nextDate = nextDate.add(const Duration(days: 1));
      } else if (rKey == 'weekly') {
        nextDate = nextDate.add(const Duration(days: 7));
      } else if (rKey == 'monthly' || rKey == 'month') {
        int nextMonth = nextDate.month + 1;
        int nextYear = nextDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int nextDay = baseDate.day > maxDays ? maxDays : baseDate.day;
        nextDate = DateTime(
          nextYear,
          nextMonth,
          nextDay,
          baseDate.hour,
          baseDate.minute,
          baseDate.second,
        );
      } else if (rKey == 'half_yearly' || rKey == 'half_year') {
        int nextMonth = nextDate.month + 6;
        int nextYear = nextDate.year;
        if (nextMonth > 12) {
          nextMonth = nextMonth - 12;
          nextYear += 1;
        }
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int nextDay = baseDate.day > maxDays ? maxDays : baseDate.day;
        nextDate = DateTime(
          nextYear,
          nextMonth,
          nextDay,
          baseDate.hour,
          baseDate.minute,
          baseDate.second,
        );
      } else if (rKey == 'yearly' || rKey == 'year') {
        int nextYear = nextDate.year + 1;
        int nextMonth = nextDate.month;
        int maxDays = DateTime(nextYear, nextMonth + 1, 0).day;
        int nextDay = baseDate.day > maxDays ? maxDays : baseDate.day;
        nextDate = DateTime(
          nextYear,
          nextMonth,
          nextDay,
          baseDate.hour,
          baseDate.minute,
          baseDate.second,
        );
      } else {
        nextDate = nextDate.add(const Duration(days: 30));
      }
    }
    
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(nextDate);
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

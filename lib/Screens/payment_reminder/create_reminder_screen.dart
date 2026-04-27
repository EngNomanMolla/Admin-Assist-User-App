import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widgets/controller/payment_controller.dart';

class CreateReminderScreen extends StatelessWidget {
  CreateReminderScreen({super.key});

  final PaymentController controller = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B39FD),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: InkWell(
            onTap: () => Get.back(),
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Create Reminder",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B39FD).withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B39FD).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notification_add_rounded, color: Color(0xFF7B39FD), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Payment Reminder",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Fill in the details to set a reminder",
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildLabel("Client Name"),
            _buildTextField(controller.nameController, "Enter client name", Icons.person_outline_rounded),
            
            const SizedBox(height: 16),
            _buildLabel("Mobile Number"),
            _buildTextField(controller.mobileController, "Enter mobile number", Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Total Amount"),
                      _buildTextField(controller.totalAmountController, "0.00", Icons.payments_outlined, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Due Amount"),
                      _buildTextField(controller.dueAmountController, "0.00", Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildLabel("Reminder Date"),
            _buildTextField(
              controller.dateTimeController, 
              "Select date & time", 
              Icons.calendar_today_rounded,
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF7B39FD)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: Color(0xFF7B39FD)),
                      ),
                      child: child!,
                    ),
                  );
                  if (time != null) {
                    final fullDateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                    controller.dateTimeController.text = DateFormat('d MMM yy • hh:mm a').format(fullDateTime);
                  }
                }
              }
            ),
            
            const SizedBox(height: 16),
            _buildLabel("Repeat Frequency"),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedRepeat.value,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF7B39FD)),
                  items: controller.repeatOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) controller.selectedRepeat.value = newValue;
                  },
                ),
              ),
            )),

            const SizedBox(height: 16),
            _buildLabel("Note"),
            _buildTextField(controller.noteController, "Add a note...", Icons.note_add_outlined, maxLines: 3),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => controller.addPaymentReminder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B39FD),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text(
                "Create Reminder",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Go Back",
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 16, 
              right: 12, 
              top: maxLines > 1 ? 16 : 0, 
              bottom: maxLines > 1 ? 0 : 0
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF7B39FD)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

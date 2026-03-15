import 'package:flutter/material.dart';
import 'package:flutter_widgets/Screens/payment_reminder/payment_details_screen.dart';
import 'package:flutter_widgets/controller/payment_controller.dart';
import 'package:flutter_widgets/Models/payment_models.dart';
import 'package:get/get.dart';

class PaymentRemainder extends StatelessWidget {
  PaymentRemainder({super.key});

  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 15, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/images/secondpic.png"),
          ),
        ),
        title: const Text(
          'Payment Reminder',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: GetBuilder<PaymentController>(
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tabButton("Today", 0),
                    _tabButton("Expire", 1),
                    _tabButton("Next Up", 2),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  final list = controller.filteredList;
                  return list.isEmpty
                      ? const Center(child: Text("No payments found"))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          physics: const BouncingScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return PaymentCard(
                              payment: list[index],
                              onDelete: () =>
                                  controller.deletePayment(list[index]),
                            );
                          },
                        );
                }),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => PaymentDetailsScreen()),
        backgroundColor: const Color(0xFF7B4DFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    bool isSelected = controller.selectedTab == index;
    return InkWell(
      onTap: () => controller.changeTab(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7B4DFF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final Function() onDelete;

  const PaymentCard({super.key, required this.payment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        payment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.push_pin_outlined,
                        size: 16,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  Text(
                    payment.time,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black45),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text("View Details"),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Partial payment pending",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Due Amount: ${payment.amount}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(Icons.call, "Call", isDark: true),
              _actionButton(Icons.chat_bubble_outline, "Message"),
              _actionButton(Icons.calendar_today_outlined, "Next Date"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

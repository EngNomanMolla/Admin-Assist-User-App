import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/screens/payment_reminder/payment_details_screen.dart';
import 'package:flutter_widgets/screens/payment_reminder/create_reminder_screen.dart';
import 'package:flutter_widgets/controller/payment_controller.dart';
import 'package:flutter_widgets/Models/payment_models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter_widgets/screens/payment_reminder/widgets/add_payment_dialog.dart';
import 'package:shimmer/shimmer.dart';

class PaymentRemainderScreen extends StatefulWidget {
  const PaymentRemainderScreen({super.key});

  @override
  State<PaymentRemainderScreen> createState() => _PaymentRemainderScreenState();
}

class _PaymentRemainderScreenState extends State<PaymentRemainderScreen> {
  final PaymentController controller = Get.put(PaymentController());
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: controller.selectedTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
          'Payment Reminder',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: GetBuilder<PaymentController>(
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B39FD).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _tabButton("Today", 0),
                      _tabButton("Expire", 1),
                      _tabButton("Next Up", 2),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: controller.isLoading.value && controller.paymentList.isEmpty
                    ? _buildShimmerList()
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchPayments(),
                        color: const Color(0xFF7B39FD),
                        backgroundColor: Colors.white,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            controller.changeTab(index);
                          },
                          children: [
                            _buildPaymentList("today"),
                            _buildPaymentList("expire"),
                            _buildPaymentList("nextup"),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () {
            controller.prepareCreate();
            Get.to(() => CreateReminderScreen());
          },
          backgroundColor: const Color(0xFF7B39FD),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildPaymentList(String status) {
    final list = controller.paymentList.where((e) => e.status == status).toList();
    return list.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return PaymentCard(
                payment: list[index],
                onDelete: () => controller.deletePayment(list[index]),
              );
            },
          );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: SizedBox(
        height: Get.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B39FD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, size: 48, color: Color(0xFF7B39FD)),
              ),
          const SizedBox(height: 16),
          const Text(
            "No payments found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You are all caught up for now.",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(height: 48, width: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16, width: 120, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 80, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 44, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(3, (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      child: Container(height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                    ),
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(String text, int index) {
    bool isSelected = controller.selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.changeTab(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7B39FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7B39FD).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
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
    final controller = Get.find<PaymentController>();
    return GestureDetector(
      onTap: () => Get.to(() => PaymentDetailsScreen(payment: payment)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B39FD).withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B39FD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded, color: const Color(0xFF7B39FD), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    payment.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: const Color(0xFF111827),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.push_pin_rounded, size: 12, color: Colors.amber.shade600),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 10, color: const Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  () {
                                    try {
                                      DateTime dt = DateTime.parse(payment.time);
                                      return DateFormat('d MMMM yyyy   h.mm a').format(dt);
                                    } catch (e) {
                                      return payment.time;
                                    }
                                  }(),
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz_rounded, color: const Color(0xFF9CA3AF), size: 20),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'delete') {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                              SizedBox(width: 12),
                              Text("Delete Reminder", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            ],
                          ),
                          content: const Text(
                            "Are you sure you want to delete this payment reminder? This action cannot be undone.",
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700)),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                onDelete();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      );
                    } else if (value == 'edit') {
                      controller.prepareEdit(payment);
                      Get.to(() => CreateReminderScreen());
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: const Color(0xFF4B5563)),
                          SizedBox(width: 10),
                          Text("Edit", style: TextStyle(color: const Color(0xFF4B5563), fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade400),
                          const SizedBox(width: 10),
                          Text("Delete", style: TextStyle(color: Colors.red.shade400, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text("Total: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
                            Text(payment.totalAmount.replaceAll('\$', ''), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF3B82F6))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B39FD).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text("Due: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF7B39FD))),
                            Text(payment.amount.replaceAll('\$', ''), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF7B39FD))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                   onTap: () {
                     if (payment.id != null) {
                       showAddPaymentDialog(context, controller, payment.id!);
                     } else {
                       Get.snackbar("Error", "Invalid payment record", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
                     }
                   },
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF7B39FD), size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _actionButton(Icons.call_rounded, "Call", const Color(0xFF10B981), () {})),
                const SizedBox(width: 8),
                Expanded(child: _actionButton(Icons.chat_bubble_rounded, "Message", const Color(0xFF3B82F6), () {})),
                const SizedBox(width: 8),
                Expanded(child: _actionButton(Icons.calendar_month_rounded, "Next", const Color(0xFFF59E0B), () async {
                   if (payment.id == null) return;
                          
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(primary: Color(0xFF7B39FD)),
                              ),
                              child: child!,
                            ),
                          );

                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(primary: Color(0xFF7B39FD)),
                                ),
                                child: child!,
                              ),
                            );

                            if (pickedTime != null) {
                              final fullDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              controller.reschedulePayment(payment, fullDateTime);
                            }
                          }
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

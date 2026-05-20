import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widgets/models/debt_model.dart';
import 'package:flutter_widgets/controller/debt_controller.dart';
import 'package:intl/intl.dart';

class DebtPaymentHistoryScreen extends StatefulWidget {
  final DebtTransaction transaction;

  const DebtPaymentHistoryScreen({super.key, required this.transaction});

  @override
  State<DebtPaymentHistoryScreen> createState() => _DebtPaymentHistoryScreenState();
}

class _DebtPaymentHistoryScreenState extends State<DebtPaymentHistoryScreen> {
  final DebtController controller = Get.find<DebtController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPaymentHistory(widget.transaction.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTx = controller.transactions.firstWhere(
        (t) => t.id == widget.transaction.id,
        orElse: () => widget.transaction,
      );

      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(
            '${currentTx.title} Payments',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF59E0B),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  // Summary Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Original Liability',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '৳${currentTx.amount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Remaining',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '৳${currentTx.remainingAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Text(
                          'Payment History',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: currentTx.payments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment_rounded, size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'No payments made yet',
                                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: currentTx.payments.length,
                            itemBuilder: (context, index) {
                              final payment = currentTx.payments[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Payment',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('MMM dd, yyyy').format(payment.date),
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '- ৳${payment.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      );
    });
  }
}

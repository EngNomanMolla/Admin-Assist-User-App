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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          '${widget.transaction.title} History',
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
      body: Obx(() {
        final isLoading = controller.isLoadingHistory.value;
        final historyRecords = controller.historyRecords;
        final summary = controller.historySummary.value;

        // If loading and no history is loaded yet, show indicator
        if (isLoading && historyRecords.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            // Summary Card
            _buildSummaryCard(summary),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: historyRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No transactions recorded yet',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: historyRecords.length,
                      itemBuilder: (context, index) {
                        final record = historyRecords[index];
                        return _buildHistoryCard(record);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic>? summary) {
    // Fallback values if summary is not loaded yet
    final double totalLiability = summary != null
        ? double.tryParse(summary['total_amount']?.toString() ?? '') ?? widget.transaction.amount
        : widget.transaction.amount;
    final double paidAmount = summary != null
        ? double.tryParse(summary['paid_amount']?.toString() ?? '') ?? 0.0
        : 0.0;
    final double remainingAmount = summary != null
        ? double.tryParse(summary['remaining_amount']?.toString() ?? '') ?? widget.transaction.remainingAmount
        : widget.transaction.remainingAmount;
    final double progressPercentage = summary != null
        ? double.tryParse(summary['progress_percentage']?.toString() ?? '') ?? (totalLiability > 0 ? (paidAmount / totalLiability * 100) : 0.0)
        : (totalLiability > 0 ? (paidAmount / totalLiability * 100) : 0.0);

    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridItem('Total Liability', totalLiability),
              ),
              Expanded(
                child: _buildSummaryGridItem('Paid Amount', paidAmount, crossAxisAlignment: CrossAxisAlignment.end),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryGridItem('Remaining Amount', remainingAmount),
              ),
              Expanded(
                child: _buildSummaryGridItemPercent('Progress', progressPercentage, crossAxisAlignment: CrossAxisAlignment.end),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGridItem(String label, double amount, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildSummaryGridItemPercent(String label, double percentage, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(2)}%',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(DebtPayment record) {
    final bool isPay = record.type == 'pay';
    final Color typeColor = isPay ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final IconData typeIcon = isPay ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final String typeText = isPay ? 'Paid Amount' : 'Borrowed Amount';
    final String sign = isPay ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(record.date),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
                if (record.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.notes,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign ৳${record.amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: typeColor),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280), size: 20),
            padding: EdgeInsets.zero,
            onSelected: (val) {
              if (val == 'edit') {
                _showEditHistoryDialog(record);
              } else if (val == 'delete') {
                _showDeleteHistoryConfirmation(record.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: Color(0xFF6B7280), size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditHistoryDialog(DebtPayment record) {
    final amountController = TextEditingController(text: record.amount.toStringAsFixed(2));
    final notesController = TextEditingController(text: record.notes);
    final Rx<DateTime> selectedDate = record.date.obs;

    Get.dialog(
      Obx(() {
        final isLoading = controller.isLoading.value;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Update Record',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Amount',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      prefixText: '৳ ',
                      prefixStyle: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate.value,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFFF59E0B),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF111827),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              selectedDate.value = picked;
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(selectedDate.value),
                            style: const TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: Color(0xFF6B7280), size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'e.g. Repayment of loan',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final editAmount = double.tryParse(amountController.text) ?? 0.0;
                                if (editAmount > 0) {
                                  final success = await controller.updateHistoryRecord(
                                    transactionId: widget.transaction.id,
                                    historyId: record.id,
                                    amount: editAmount,
                                    notes: notesController.text,
                                    date: selectedDate.value,
                                    type: record.type,
                                  );
                                  if (success && mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteHistoryConfirmation(String historyId) {
    Get.dialog(
      Obx(() {
        final isLoading = controller.isLoading.value;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this history record?'),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final success = await controller.deleteHistoryRecord(
                        transactionId: widget.transaction.id,
                        historyId: historyId,
                      );
                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/todo_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TodoDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> todo;

  const TodoDetailsScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoController>(
      builder: (controller) {
        final int todoId = int.tryParse(todo['id'].toString()) ?? 0;
        // Check if the current todo in the list has been updated to 'complete'
        var currentTodo = controller.todoList.firstWhere((e) => e['id'].toString() == todo['id'].toString(), orElse: () => todo);
        bool isCompleted = currentTodo['status'].toString().toLowerCase() == 'complete';
        bool isProcessing = controller.processingTodoId == todoId;

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
              'Task Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Card
                Container(
                  padding: const EdgeInsets.all(20),
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
                    border: Border.all(color: isCompleted ? const Color(0xFF10B981).withOpacity(0.3) : Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF7B39FD).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentTodo['status']?.toString().capitalizeFirst ?? 'Ongoing',
                              style: TextStyle(
                                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF7B39FD),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(Icons.push_pin_rounded, color: Color(0xFFF59E0B), size: 20),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentTodo['title'] ?? 'Untitled Task',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoBadge(
                              Icons.calendar_month_rounded, 
                              "Date", 
                              _formatDate(currentTodo['due_date']), 
                              const Color(0xFFF59E0B)
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoBadge(
                              Icons.access_time_filled_rounded, 
                              "Time", 
                              _formatTime(currentTodo['due_date']), 
                              const Color(0xFF3B82F6)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Notes Card
                const Text(
                  "Notes & Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B39FD).withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: (currentTodo['notes'] == null || currentTodo['notes'].toString().isEmpty)
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No notes added.",
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            ),
                          ),
                        )
                      : Text(
                          currentTodo['notes'].toString(),
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildBottomAction(
                  icon: Icons.delete_outline_rounded,
                  label: "Delete",
                  color: Colors.red.shade400,
                  onTap: () => _showDeleteConfirmation(context, controller, todoId),
                ),
                const SizedBox(width: 12),
                _buildBottomAction(
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  color: const Color(0xFF3B82F6),
                  onTap: (isCompleted || isProcessing) ? null : () {
                    controller.prepareEdit(currentTodo);
                    Get.back(result: 'edit'); // Send edit signal back
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: (isCompleted || isProcessing) ? null : () => controller.markDone(currentTodo),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF10B981) : (isProcessing ? Colors.grey.shade300 : const Color(0xFF10B981)),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (isCompleted || isProcessing) ? [] : [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isProcessing 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isProcessing ? "Updating..." : (isCompleted ? "Completed" : "Mark Done"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showDeleteConfirmation(BuildContext context, TodoController controller, int id) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 32),
              ),
              const SizedBox(height: 20),
              const Text("Delete Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to delete this task? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Close details screen
                        controller.deleteTodo(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dueDate) {
    if (dueDate == null || dueDate.toString().isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dueDate.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return "N/A";
    }
  }

  String _formatTime(dynamic dueDate) {
    if (dueDate == null || dueDate.toString().isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dueDate.toString());
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return "N/A";
    }
  }

  Widget _buildInfoBadge(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({required IconData icon, required String label, required Color color, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(onTap == null ? 0.1 : 0.2)),
        ),
        child: Center(
          child: Icon(icon, size: 22, color: color.withOpacity(onTap == null ? 0.4 : 1.0)),
        ),
      ),
    );
  }
}

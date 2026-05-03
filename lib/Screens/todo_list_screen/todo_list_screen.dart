import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/todo_controller.dart';
import 'package:flutter_widgets/screens/todo_list_screen/todo_details_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoController>(
      init: TodoController(),
      builder: (controller) {
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
            title: controller.isSearching
                ? TextField(
                    controller: controller.searchController,
                    onChanged: controller.updateSearchQuery,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Search tasks...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                  )
                : const Text(
                    'To-Do List Planner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  controller.isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: controller.toggleSearch,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              _buildCategories(controller),
              Expanded(
                child: controller.isLoading && controller.todoList.isEmpty
                    ? _buildShimmerList()
                    : controller.filteredTodoList.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => controller.fetchTodos(),
                            color: const Color(0xFF7B39FD),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.filteredTodoList.length,
                              itemBuilder: (context, index) {
                                var todo = controller.filteredTodoList[index];
                                return _buildTodoCard(todo, controller, context);
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: SizedBox(
            width: 52,
            height: 52,
            child: FloatingActionButton(
              onPressed: () {
                controller.prepareCreate();
                _showAddTaskSheet(context, controller);
              },
              backgroundColor: const Color(0xFF7B39FD),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategories(TodoController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        height: 52,
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
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            bool isSelected = controller.selectedTab == index;
            return Builder(
              builder: (itemContext) {
                return GestureDetector(
                  onTap: () {
                    controller.changeTab(index);
                    Scrollable.ensureVisible(
                      itemContext,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: 0.5,
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF7B39FD) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.categories[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF7B39FD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_note_rounded, size: 48, color: Color(0xFF7B39FD)),
          ),
          const SizedBox(height: 16),
          const Text(
            "No tasks found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You are all caught up for now.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Map<String, dynamic> todo, TodoController controller, BuildContext context) {
    int todoId = int.tryParse(todo['id'].toString()) ?? 0;
    bool isCompleted = todo['status'].toString().toLowerCase() == 'complete';
    bool isProcessing = controller.processingTodoId == todoId;

    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => TodoDetailsScreen(todo: todo));
        if (result == 'edit') {
           _showAddTaskSheet(context, controller);
        }
      },
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
          border: Border.all(color: isCompleted ? const Color(0xFF10B981).withOpacity(0.3) : Colors.grey.shade100),
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
                      GestureDetector(
                        onTap: (isCompleted || isProcessing) ? null : () => controller.markDone(todo),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF7B39FD).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: isProcessing 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF7B39FD), strokeWidth: 2))
                            : Icon(
                                isCompleted ? Icons.check_circle_rounded : Icons.assignment_rounded, 
                                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF7B39FD), 
                                size: 20
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF111827),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDueDate(todo['due_date']),
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500),
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
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.more_horiz_rounded, color: Color(0xFF6B7280), size: 20),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      controller.prepareEdit(todo);
                      _showAddTaskSheet(context, controller);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, controller, todoId);
                    }
                  },
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      enabled: !isCompleted,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined, 
                            size: 16, 
                            color: isCompleted ? Colors.grey.shade400 : const Color(0xFF4B5563)
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Edit", 
                            style: TextStyle(
                              color: isCompleted ? Colors.grey.shade400 : const Color(0xFF4B5563), 
                              fontSize: 13
                            )
                          ),
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
            if (todo['notes'] != null && todo['notes'].toString().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 6),
                    Text(
                      todo['notes'].toString(),
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _actionButton(
                    isProcessing ? Icons.hourglass_empty_rounded : (isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded), 
                    isProcessing ? "Updating..." : (isCompleted ? "Completed" : "Mark Done"), 
                    isCompleted ? const Color(0xFF10B981) : const Color(0xFF6B7280), 
                    onTap: (isCompleted || isProcessing) ? null : () => controller.markDone(todo)
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _actionButton(Icons.visibility_outlined, "View Details", const Color(0xFF3B82F6), onTap: () async {
                  var result = await Get.to(() => TodoDetailsScreen(todo: todo));
                  if (result == 'edit') {
                    if (context.mounted) _showAddTaskSheet(context, controller);
                  }
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(dynamic dueDate) {
    if (dueDate == null || dueDate.toString().isEmpty) return "No date set";
    try {
      DateTime dt = DateTime.parse(dueDate.toString());
      return DateFormat('dd MMM yyyy  hh:mm a').format(dt);
    } catch (e) {
      return dueDate.toString();
    }
  }

  Widget _actionButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
                        Get.back();
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

  void _showAddTaskSheet(BuildContext context, TodoController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 12,
          left: 24,
          right: 24,
        ),
        child: GetBuilder<TodoController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        controller.isEditing ? Icons.edit_note_rounded : Icons.add_task_rounded, 
                        color: const Color(0xFF7B39FD)
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isEditing ? "Edit Task" : "Create New Task",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Task Title"),
                  _buildTextField(controller.titleController, "What needs to be done?"),
                  const SizedBox(height: 16),
                  _buildLabel("Notes & Details"),
                  _buildTextField(controller.notesController, "Add any extra notes...", maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Date & Time"),
                            _buildTextField(
                              controller.dateController,
                              "Select",
                              icon: Icons.calendar_today_rounded,
                              readOnly: true,
                              onTap: () => controller.selectDate(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Repeat"),
                            _buildDropdown(controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancel", style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : () async {
                            bool success = await controller.saveTodo();
                            if (success) {
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B39FD),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(controller.isEditing ? "Update Task" : "Create Task", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF6B7280), size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(TodoController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedRepeat,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280), size: 20),
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontWeight: FontWeight.w500),
          onChanged: (val) => controller.setRepeat(val),
          items: controller.repeatOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalizeFirst!)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B39FD).withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 150, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 8),
                          Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

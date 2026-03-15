import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/todo_controller.dart';
import 'package:get/get.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoController>(
      init: TodoController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 15),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('assets/images/secondpic.png'),
              ),
            ),
            title: const Text(
              'To-Do list Planner',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF6C63FF),
                  size: 28,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 70,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  itemBuilder: (context, index) {
                    bool isSelected = controller.selectedTab == index;
                    return GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF7B61FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            controller.categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: controller.filteredTodoList.isEmpty
                    ? const Center(child: Text("No Tasks Available"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.filteredTodoList.length,
                        itemBuilder: (context, index) {
                          var todo = controller.filteredTodoList[index];
                          return _buildTodoCard(todo, controller);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF7B61FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () => _showAddTaskSheet(context, controller),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }

  void _showAddTaskSheet(BuildContext context, TodoController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Add Task",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel("Title"),
            _buildTextField(controller.titleController, "Title"),
            const SizedBox(height: 15),
            _buildLabel("Notes"),
            _buildTextField(controller.notesController, "Notes", maxLines: 3),
            const SizedBox(height: 15),
            _buildLabel("Repeat"),
            _buildDropdown(controller),
            const SizedBox(height: 15),
            _buildLabel("Date & Time"),
            _buildTextField(
              controller.dateController,
              "Date & time",
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: () => controller.selectDate(context),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.addTodoFromForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(TodoController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedRepeat,
          isExpanded: true,
          onChanged: (val) => controller.setRepeat(val),
          items: controller.repeatOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTodoCard(Map<String, dynamic> todo, TodoController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${todo['date']}  • ${todo['time']}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todo['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Notes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...((todo['notes'] as List).map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "• $note",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          )),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Text(
                "View",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              label: const Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

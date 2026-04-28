import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TodoController extends GetxController {
  int selectedTab = 0;
  final List<String> categories = ['Today', 'Expire', 'Next Up', 'Ongoing'];

  List<Map<String, dynamic>> todoList = [
    {
      'title': 'Branch Manager Progress M',
      'date': '25 July 2025',
      'time': '4:00 PM',
      'status': 'Today',
      'notes': [
        'Monthly target review',
        'Discuss staff performance',
        'Next action plan',
      ],
    },
    {
      'title': 'Branch Manager Progress M',
      'date': '25 July 2025',
      'time': '4:00 PM',
      'status': 'Today',
      'notes': [
        'Monthly target review',
        'Discuss staff performance',
        'Next action plan',
      ],
    },

    {
      'title': 'Branch Manager Progress M',
      'date': '25 July 2025',
      'time': '4:00 PM',
      'status': 'Today',
      'notes': [
        'Monthly target review',
        'Discuss staff performance',
        'Next action plan',
      ],
    },
  ];

  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String selectedRepeat = "Once";
  List<String> repeatOptions = ["Once", "Daily", "Weekly", "Monthly"];

  bool isSearching = false;
  String searchQuery = "";

  List<Map<String, dynamic>> get filteredTodoList {
    var list = todoList.where((e) => e['status'] == categories[selectedTab]).toList();
    if (searchQuery.isNotEmpty) {
      list = list.where((e) {
        final title = e['title'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query);
      }).toList();
    }
    return list;
  }

  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchQuery = "";
      searchController.clear();
    }
    update();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    update();
  }

  void changeTab(int index) {
    selectedTab = index;
    update();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      update();
    }
  }

  void setRepeat(String? value) {
    selectedRepeat = value ?? "Once";
    update();
  }

  void addTodoFromForm() {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Title cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    todoList.add({
      'title': titleController.text,
      'date': dateController.text.isEmpty
          ? DateFormat('dd MMMM yyyy').format(DateTime.now())
          : dateController.text,
      'time': DateFormat('h:mm a').format(DateTime.now()),
      'status': 'Today',
      'notes': notesController.text.split('\n'),
    });

    titleController.clear();
    notesController.clear();
    dateController.clear();
    update();
    Get.back();
  }
}

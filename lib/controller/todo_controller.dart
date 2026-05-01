import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/provider/todo_provider.dart';
import 'package:flutter_widgets/services/local_db_service.dart';
import 'package:flutter_widgets/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TodoController extends GetxController {
  final TodoProvider _todoProvider = TodoProvider();
  
  int selectedTab = 0;
  final List<String> categories = ['Today', 'Expire', 'Next Up', 'Complete'];
  
  final Map<String, String> categoryStatusMap = {
    'Today': 'today',
    'Expire': 'expire',
    'Next Up': 'nextup',
    'Complete': 'complete',
  };

  bool isLoading = false;
  int? processingTodoId; // Track which todo is being updated/deleted
  DateTime? selectedDateTime;

  List<Map<String, dynamic>> todoList = [];

  // Edit Mode State
  bool isEditing = false;
  int? editingTodoId;

  @override
  void onInit() {
    super.onInit();
    // Request notification permissions when initializing
    NotificationService().requestPermissions();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      isLoading = true;
      update();
      
      final response = await _todoProvider.getTodos('all');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
           todoList = List<Map<String, dynamic>>.from(data);
        } else if (data['todos'] != null) {
           todoList = List<Map<String, dynamic>>.from(data['todos']);
        }
        
        // Sync local DB (Optional: insert all fetched todos)
        for (var todo in todoList) {
          await LocalDBService().upsertTodo(todo);
          // We could also re-schedule notifications here if needed
        }
      } else {
        // Fallback: load from local DB if API fails
        todoList = await LocalDBService().getTodos();
      }
    } catch (e) {
      print("Error fetching todos: $e");
      // Fallback: load from local DB if network error
      todoList = await LocalDBService().getTodos();
    } finally {
      isLoading = false;
      update();
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String selectedRepeat = "once";
  List<String> repeatOptions = ["once", "daily", "weekly", "monthly"];

  bool isSearching = false;
  String searchQuery = "";

  List<Map<String, dynamic>> get filteredTodoList {
    String currentStatus = categoryStatusMap[categories[selectedTab]] ?? 'today';
    var list = todoList.where((e) => e['status'].toString().toLowerCase() == currentStatus).toList();
    
    if (searchQuery.isNotEmpty) {
      list = list.where((e) {
        final title = (e['title'] ?? '').toString().toLowerCase();
        final notes = (e['notes'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query) || notes.contains(query);
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
    final DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7B39FD),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null ? TimeOfDay.fromDateTime(selectedDateTime!) : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF7B39FD),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        dateController.text = DateFormat('dd MMM yyyy, hh:mm a').format(selectedDateTime!);
        update();
      }
    }
  }

  void setRepeat(String? value) {
    selectedRepeat = value ?? "once";
    update();
  }

  void prepareCreate() {
    isEditing = false;
    editingTodoId = null;
    titleController.clear();
    notesController.clear();
    dateController.clear();
    selectedDateTime = null;
    selectedRepeat = "once";
    update();
  }

  void prepareEdit(Map<String, dynamic> todo) {
    isEditing = true;
    editingTodoId = int.tryParse(todo['id'].toString());
    titleController.text = todo['title'] ?? '';
    notesController.text = todo['notes']?.toString() ?? '';
    selectedRepeat = todo['repeat']?.toString().toLowerCase() ?? 'once';
    
    if (todo['due_date'] != null) {
      try {
        selectedDateTime = DateTime.parse(todo['due_date'].toString());
        dateController.text = DateFormat('dd MMM yyyy, hh:mm a').format(selectedDateTime!);
      } catch (e) {
        dateController.clear();
        selectedDateTime = null;
      }
    } else {
      dateController.clear();
      selectedDateTime = null;
    }
    update();
  }

  Future<bool> saveTodo() async {
    if (titleController.text.isEmpty) {
      Get.snackbar("Error", "Title cannot be empty", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    }
    if (selectedDateTime == null) {
      Get.snackbar("Error", "Please select date and time", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    }

    try {
      isLoading = true;
      update();

      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!);
      Map<String, dynamic> data = {
        "title": titleController.text,
        "notes": notesController.text,
        "repeat": selectedRepeat.toLowerCase(),
        "due_date": formattedDate,
      };

      final response = isEditing 
          ? await _todoProvider.updateTodo(editingTodoId!, data)
          : await _todoProvider.createTodo(data);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Assume API returns the created/updated task object in 'data' or 'todo'
        // For local storage, we will construct it manually since we might not have the full returned object
        int todoId = isEditing ? editingTodoId! : 0; 
        
        // If it's a create, the API should return the ID. Let's try to parse it if available.
        try {
          final resData = jsonDecode(response.body);
          if (resData['todo'] != null && resData['todo']['id'] != null) {
            todoId = int.tryParse(resData['todo']['id'].toString()) ?? todoId;
          } else if (resData['id'] != null) {
            todoId = int.tryParse(resData['id'].toString()) ?? todoId;
          }
        } catch (e) {}

        // 1. Store in Local Database
        Map<String, dynamic> localData = {
          "id": todoId,
          "title": titleController.text,
          "notes": notesController.text,
          "repeat": selectedRepeat.toLowerCase(),
          "due_date": formattedDate,
          "status": "today" // default status or what API expects
        };
        await LocalDBService().upsertTodo(localData);

        // 2. Schedule Notification
        if (todoId != 0) {
          await NotificationService().scheduleTaskNotification(
            todoId,
            titleController.text,
            notesController.text.isNotEmpty ? notesController.text : "Task Reminder",
            selectedDateTime!,
            repeat: selectedRepeat.toLowerCase(),
          );
        }

        if (!isEditing) {
           DateTime now = DateTime.now();
           bool isToday = selectedDateTime!.year == now.year &&
                          selectedDateTime!.month == now.month &&
                          selectedDateTime!.day == now.day;
           selectedTab = isToday ? 0 : 2;
        }

        Get.snackbar("Success", isEditing ? "Task updated successfully" : "Task created successfully", 
            backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        
        fetchTodos();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to save task", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print("Error saving todo: $e");
      Get.snackbar("Error", "Something went wrong", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      isLoading = true;
      processingTodoId = id;
      update();
      
      final response = await _todoProvider.deleteTodo(id);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 1. Remove from Local DB
        await LocalDBService().deleteTodo(id);
        
        // 2. Cancel Notification
        await NotificationService().cancelNotification(id);

        Get.snackbar("Success", "Task deleted successfully", backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        fetchTodos();
      } else {
        Get.snackbar("Error", "Failed to delete task", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print("Error deleting todo: $e");
    } finally {
      isLoading = false;
      processingTodoId = null;
      update();
    }
  }

  Future<void> markDone(Map<String, dynamic> todo) async {
    int id = int.tryParse(todo['id'].toString()) ?? 0;
    if (id == 0) return;

    try {
      isLoading = true;
      processingTodoId = id;
      update();

      String formattedDueDate = "";
      if (todo['due_date'] != null) {
        try {
          DateTime dt = DateTime.parse(todo['due_date'].toString());
          formattedDueDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
        } catch (e) {
          formattedDueDate = todo['due_date'].toString();
        }
      }

      Map<String, dynamic> data = {
        "title": todo['title']?.toString() ?? '',
        "notes": todo['notes']?.toString() ?? '',
        "repeat": (todo['repeat'] ?? 'once').toString().toLowerCase(),
        "due_date": formattedDueDate,
        "status": "complete",
      };

      final response = await _todoProvider.updateTodo(id, data);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 1. Update Local DB
        data['id'] = id;
        await LocalDBService().upsertTodo(data);

        // 2. Cancel Notification since it's complete
        await NotificationService().cancelNotification(id);

        Get.snackbar("Success", "Task marked as complete", backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        fetchTodos();
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['message'] ?? "Failed to update task status";
        Get.snackbar("Error", errorMsg, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print("Error marking todo as done: $e");
      Get.snackbar("Error", "Network error occurred", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      isLoading = false;
      processingTodoId = null;
      update();
    }
  }
}

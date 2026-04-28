import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/provider/dashboard_provider.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void updateIndex(int index) => currentIndex.value = index;
}

class HomeController extends GetxController {
  final DashboardProvider _dashboardProvider = DashboardProvider();
  
  var notices = <Map<String, dynamic>>[].obs;
  var banners = <Map<String, dynamic>>[].obs;
  var quickAccess = {}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final response = await _dashboardProvider.getDashboardData();
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        notices.value = List<Map<String, dynamic>>.from(data['live_notices'] ?? []);
        banners.value = List<Map<String, dynamic>>.from(data['banners'] ?? []);
        quickAccess.value = data['quick_access'] ?? {};
      } else {
        Get.snackbar("Error", "Failed to load dashboard data");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error fetching dashboard: $e");
      Get.snackbar("Error", "Something went wrong while loading dashboard");
    }
  }
}

import 'dart:convert';
import 'package:flutter_widgets/provider/job_provider.dart';
import 'package:get/get.dart';

class JobController extends GetxController {
  final JobProvider _jobProvider = JobProvider();
  
  var jobList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      isLoading.value = true;
      final response = await _jobProvider.getJobCirculars();
      isLoading.value = false;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        jobList.value = List<Map<String, dynamic>>.from(data);
      } else {
        Get.snackbar("Error", "Failed to fetch job circulars");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error fetching jobs: $e");
      Get.snackbar("Error", "Something went wrong while loading jobs");
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/provider/user_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final ImagePicker _picker = ImagePicker();
  
  var userData = <String, dynamic>{}.obs;
  var isLoading = false.obs;
  var isImageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final response = await _userProvider.getUserProfile();
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData.value = Map<String, dynamic>.from(data);
      } else {
        Get.snackbar("Error", "Failed to load profile data");
      }
    } catch (e) {
      isLoading.value = false;
      print("Error fetching profile: $e");
      Get.snackbar("Error", "Something went wrong while loading profile");
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    try {
      isLoading.value = true;
      final response = await _userProvider.updateProfile({
        'name': name,
        'phone': phone,
      });
      isLoading.value = false;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        fetchUserProfile(); // Refresh data
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          "Error", 
          data['message'] ?? "Failed to update profile",
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error", 
        "Something went wrong",
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  Future<bool> changePassword(String current, String password, String confirm) async {
    try {
      isLoading.value = true;
      final response = await _userProvider.changePassword({
        'old_password': current,
        'password': password,
        'password_confirmation': confirm,
      });
      isLoading.value = false;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          "Error", 
          data['message'] ?? "Failed to change password",
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error", 
        "Something went wrong",
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Optimize for upload
      );

      if (image != null) {
        isImageUploading.value = true;
        final response = await _userProvider.uploadProfileImage(image.path);
        isImageUploading.value = false;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data['user'] != null) {
            userData.value = Map<String, dynamic>.from(data['user']);
          }
          
          Get.snackbar(
            "Success", 
            "Profile picture updated successfully",
            backgroundColor: const Color(0xFF10B981).withOpacity(0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          );
        } else {
          final data = jsonDecode(response.body);
          Get.snackbar("Error", data['message'] ?? "Failed to upload image");
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Could not pick or upload image");
    }
  }

  String get fullProfilePicUrl {
    final path = userData['profile_picture'];
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    return "https://mentorassist.online/$path";
  }

  String get verifiedDate {
    try {
      if (userData['email_verified_at'] == null) return "N/A";
      final date = DateTime.parse(userData['email_verified_at']!);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return "N/A";
    }
  }
}

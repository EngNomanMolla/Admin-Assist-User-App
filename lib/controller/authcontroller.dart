import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/provider/auth_provider.dart';
import 'package:flutter_widgets/screens/login_screens/email_verification_screen.dart';
import 'package:flutter_widgets/screens/navigation button.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final GetStorage _storage = GetStorage();
  
  final mobileController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();

  final forgotEmailPhoneController = TextEditingController();

  final otpControllers = List.generate(4, (index) => TextEditingController());
  final otpFocusNodes = List.generate(4, (index) => FocusNode());

  final newPasswordController = TextEditingController();
  final rewritePasswordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isRememberMeChecked = false.obs;

  var isNewPassVisible = false.obs;
  var isConfirmPassVisible = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if Remember Me was checked previously
    isRememberMeChecked.value = _storage.read('rememberMe') ?? false;
    if (isRememberMeChecked.value) {
      emailController.text = _storage.read('savedEmail') ?? '';
      loginPasswordController.text = _storage.read('savedPassword') ?? '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    isRememberMeChecked.value = value ?? false;
  }

  void login() async {
    String email = emailController.text.trim();
    String password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both email and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      // No Get.dialog here, we use in-button loading in the UI

      final response = await _authProvider.login(email, password);
      
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        
        // Always save token for the current session's API calls
        _storage.write('token', token);
        _storage.write('userData', data['user']);
        
        // Save persistent session only if Remember Me is checked
        if (isRememberMeChecked.value) {
          _storage.write('isLoggedIn', true);
          _storage.write('rememberMe', true);
          _storage.write('savedEmail', email);
          _storage.write('savedPassword', password);
        } else {
          _storage.write('isLoggedIn', false);
          _storage.write('rememberMe', false);
          _storage.remove('savedEmail');
          _storage.remove('savedPassword');
        }
        
        // Get.snackbar("Success", "Logged in successfully", snackPosition: SnackPosition.BOTTOM);
        Get.offAll(() => const NavigationScreen());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Login Failed",
          error['message'] ?? "Invalid credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong. Please try again.", snackPosition: SnackPosition.BOTTOM);
      print("Login Error: $e");
    }
  }

  void signup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = signupPhoneController.text.trim();
    String password = signupPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authProvider.signup({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Account created successfully. Verification code sent to your email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.to(() => const EmailVerificationScreen());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Registration Failed",
          error['message'] ?? "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong. Please try again.", snackPosition: SnackPosition.BOTTOM);
      print("Signup Error: $e");
    }
  }

  void sendResetLink() {
    String input = forgotEmailPhoneController.text.trim();

    if (input.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email or phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    print("Sending reset code to: $input");
    Get.toNamed('/otp-verification');
  }

  void verifyOTP() async {
    String otp = otpControllers.map((e) => e.text).join();
    String email = emailController.text.trim();

    if (otp.length < 4) {
      Get.snackbar(
        "Error",
        "Please enter all 4 digits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF7B39FD))),
        barrierDismissible: false,
      );

      final response = await _authProvider.verifyOTP(email, otp);
      
      Get.back(); // Close loading dialog
      isLoading.value = false;

      if (response.statusCode == 200) {
        // Get.snackbar("Success", "Email verified successfully", snackPosition: SnackPosition.BOTTOM);
        for (var c in otpControllers) {
          c.clear();
        }
        Get.offAll(() => const NavigationScreen());
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Verification Failed",
          error['message'] ?? "Invalid OTP code",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong. Please try again.", snackPosition: SnackPosition.BOTTOM);
      print("Verification Error: $e");
    }
  }

  void resendCode() {
    print("Resending OTP code...");
    Get.snackbar("Success", "OTP Resent Successfully", snackPosition: SnackPosition.BOTTOM);
  }

  void continueWithGoogle() {
    print("Google Auth Tapped");
  }

  void resetPassword() {
    String pass1 = newPasswordController.text.trim();
    String pass2 = rewritePasswordController.text.trim();

    if (pass1.isEmpty || pass2.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (pass1 != pass2) {
      Get.snackbar(
        "Error",
        "Passwords do not match!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print("Password reset successful");
    Get.offAllNamed('/login');
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF7B39FD))),
        barrierDismissible: false,
      );

      final response = await _authProvider.logout();
      
      Get.back(); // Close loading dialog
      isLoading.value = false;

      // Even if API fails, we clear local session for safety
      _storage.write('isLoggedIn', false);
      _storage.remove('token');
      _storage.remove('userData');
      
      Get.offAllNamed('/login');
      Get.snackbar("Success", "Logged out successfully", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      isLoading.value = false;
      print("Logout Error: $e");
      
      // Still logout locally
      _storage.write('isLoggedIn', false);
      _storage.remove('token');
      _storage.remove('userData');
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    loginPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    signupPhoneController.dispose();
    signupPasswordController.dispose();
    forgotEmailPhoneController.dispose();
    newPasswordController.dispose();
    rewritePasswordController.dispose();

    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }

    super.onClose();
  }
}

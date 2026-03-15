import 'package:flutter/material.dart';
import 'package:flutter_widgets/Screens/navigation%20button.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final mobileController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();

  final forgotEmailPhoneController = TextEditingController();

  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());

  final newPasswordController = TextEditingController();
  final rewritePasswordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isRememberMeChecked = false.obs;

  var isNewPassVisible = false.obs;
  var isConfirmPassVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    isRememberMeChecked.value = value ?? false;
  }

  void login() {
    String mobile = mobileController.text.trim();
    String password = loginPasswordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both mobile and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    print("Logging in with: $mobile");

    Get.offAll(() => const NavigationScreen());
  }

  void signup() {
    print("Signing up user: ${nameController.text}");
    Get.toNamed('/otp-verification');
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

  void verifyOTP() {
    String otp = otpControllers.map((e) => e.text).join();

    if (otp.length < 6) {
      Get.snackbar(
        "Error",
        "Please enter all 6 digits",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    print("Verifying OTP: $otp");
    Get.toNamed('/reset-password');
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

  void resendCode() {
    print("Resending OTP code...");
    Get.snackbar("Success", "OTP Resent Successfully");
  }

  void continueWithGoogle() {
    print("Google Auth Tapped");
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

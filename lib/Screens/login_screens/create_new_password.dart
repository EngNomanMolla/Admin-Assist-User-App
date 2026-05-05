import 'package:flutter/material.dart';
import 'package:flutter_widgets/controller/authcontroller.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                "Create New Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B39FD),
                ),
              ),
              const SizedBox(height: 50),

              _buildLabel("New Password"),
              Obx(
                () => _buildTextField(
                  controller: controller.newPasswordController,
                  isVisible: controller.isNewPassVisible,
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel("Rewrite Password"),
              Obx(
                () => _buildTextField(
                  controller: controller.rewritePasswordController,
                  isVisible: controller.isConfirmPassVisible,
                ),
              ),

              const SizedBox(height: 40),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.resetPassword(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B39FD),
                      disabledBackgroundColor: const Color(0xFF7B39FD).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : const Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required RxBool isVisible,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible.value,
        decoration: InputDecoration(
          hintText: "********",
          hintStyle: TextStyle(color: Colors.grey.shade300),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible.value ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => isVisible.toggle(),
          ),
        ),
      ),
    );
  }
}

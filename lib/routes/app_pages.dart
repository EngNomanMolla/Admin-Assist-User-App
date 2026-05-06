import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_widgets/routes/app_routes.dart';
import 'package:flutter_widgets/screens/login_screens/create_new_password.dart';
import 'package:flutter_widgets/screens/login_screens/forgot_password_screen.dart';
import 'package:flutter_widgets/screens/login_screens/login_screen.dart';
import 'package:flutter_widgets/screens/login_screens/email_verification_screen.dart';
import 'package:flutter_widgets/screens/login_screens/otp_verification_screen.dart';
import 'package:flutter_widgets/screens/login_screens/signup_screen.dart';
import 'package:flutter_widgets/screens/navigation button.dart';
import 'package:flutter_widgets/controller/auth_binding.dart';

class AppPages {
  static String get INITIAL {
    final storage = GetStorage();
    if (storage.read('isLoggedIn') == true) {
      final userData = storage.read('userData');
      if (userData != null && userData['email_verified_at'] == null) {
        return AppRoutes.EMAIL_VERIFICATION;
      }
      return AppRoutes.NAVIGATION;
    }
    return AppRoutes.LOGIN;
  }

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFICATION,
      page: () => const OTPVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.NAVIGATION,
      page: () => const NavigationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.EMAIL_VERIFICATION,
      page: () => const EmailVerificationScreen(),
      binding: AuthBinding(),
    ),
  ];
}

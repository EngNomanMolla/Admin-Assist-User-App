import 'package:get/get.dart';
import 'package:flutter_widgets/routes/app_routes.dart';
import 'package:flutter_widgets/screens/login_screens/create_new_password.dart';
import 'package:flutter_widgets/screens/login_screens/forgot_password_screen.dart';
import 'package:flutter_widgets/screens/login_screens/login_screen.dart';
import 'package:flutter_widgets/screens/login_screens/otp_verification_screen.dart';
import 'package:flutter_widgets/screens/login_screens/signup_screen.dart';
import 'package:flutter_widgets/screens/navigation%20button.dart';

class AppPages {
  static const INITIAL = AppRoutes.NAVIGATION;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFICATION,
      page: () => const OTPVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.NAVIGATION,
      page: () => const NavigationScreen(),
    ),
  ];
}

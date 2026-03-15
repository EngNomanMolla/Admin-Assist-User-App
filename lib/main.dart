// import 'package:flutter/material.dart';
// import 'package:flutter_widgets/Screens/home_screen.dart';
// import 'package:flutter_widgets/Screens/login_pages/login.dart';
// import 'package:flutter_widgets/Screens/navigation%20button.dart';

// import 'package:get/get.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       // home: NavigationScreen(),
//       home: LoginScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';

import 'package:flutter_widgets/Screens/login_pages/create_new_password.dart';
import 'package:flutter_widgets/Screens/login_pages/forgot_password_screen.dart';
import 'package:flutter_widgets/Screens/login_pages/login.dart';
import 'package:flutter_widgets/Screens/login_pages/otp_verification_screen.dart';
import 'package:flutter_widgets/Screens/login_pages/signup_screen.dart';
import 'package:flutter_widgets/Screens/navigation%20button.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: '/otp-verification',
          page: () => const OTPVerificationScreen(),
        ),

        GetPage(
          name: '/reset-password',
          page: () => const ResetPasswordScreen(),
        ),

        GetPage(name: '/navigation', page: () => const NavigationScreen()),
      ],
    );
  }
}

import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ApiProvider {
  // Login request
  Future<http.Response> login(String email, String password) => postRequest(
        '/user/login',
        {
          'email': email,
          'password': password,
        },
      );

  // Signup request
  Future<http.Response> signup(Map<String, dynamic> data) => postRequest('/user/register', data);

  // OTP Verification
  Future<http.Response> verifyOTP(String email, String otp) => postRequest(
        '/user/login/email/verify',
        {
          'email': email,
          'otp': otp,
        },
      );

  // Forgot Password
  Future<http.Response> forgotPassword(String email) => postRequest('/password/forgot', {'email': email});

  // Verify Forgot Password OTP
  Future<http.Response> verifyForgotPasswordOTP(String email, String otp) => postRequest(
        '/password/verify-otp',
        {
          'email': email,
          'otp': otp,
        },
      );

  // Reset Password
  Future<http.Response> resetPassword(Map<String, dynamic> data) => postRequest('/password/reset', data);

  // Logout request
  Future<http.Response> logout() => postRequest('/logout', {});

  // Delete Account request
  Future<http.Response> deleteAccount(String password) => deleteRequest(
        '/user',
        {'password': password},
      );

  // Resend OTP request
  Future<http.Response> resendOTP(String email) => postRequest(
        '/user/login/email',
        {'email': email},
      );
}

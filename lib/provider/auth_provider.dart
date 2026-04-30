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
  Future<http.Response> signup(Map<String, dynamic> data) => postRequest('/signup', data);

  // OTP Verification
  Future<http.Response> verifyOTP(String email, String otp) => postRequest(
        '/user/login/email/verify',
        {
          'email': email,
          'otp': otp,
        },
      );

  // Forgot Password
  Future<http.Response> forgotPassword(String email) => postRequest('/forgot-password', {'email': email});

  // Logout request
  Future<http.Response> logout() => postRequest('/logout', {});
}

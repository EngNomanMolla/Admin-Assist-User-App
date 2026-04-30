import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ApiProvider {
  Future<http.Response> getUserProfile() => getRequest('/user');

  Future<http.Response> updateProfile(Map<String, String> data) =>
      postFormRequest('/user/profile', data);

  Future<http.Response> changePassword(Map<String, String> data) =>
      postRequest('/user/password/change', data);

  Future<http.Response> uploadProfileImage(String filePath) =>
      postMultipart('/user/profile', 'profile_picture', filePath);
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiProvider {
  final String baseUrl = 'https://mentorassist.online/api';

  Map<String, String> get _headers {
    final storage = GetStorage();
    final token = storage.read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('API Post Error: $e');
      rethrow;
    }
  }

  Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(
        url,
        headers: _headers,
      );
      return response;
    } catch (e) {
      print('API Get Error: $e');
      rethrow;
    }
  }
}

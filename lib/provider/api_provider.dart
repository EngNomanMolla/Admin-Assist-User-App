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

  Future<http.Response> postFormRequest(String endpoint, Map<String, String> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final storage = GetStorage();
    final token = storage.read('token');
    
    // For form data, we don't set Content-Type to application/json
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body, // http package handles Map as form-data
      );
      return response;
    } catch (e) {
      print('API Form Post Error: $e');
      rethrow;
    }
  }

  Future<http.Response> postMultipart(String endpoint, String fieldName, String filePath) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      var request = http.MultipartRequest('POST', url);
      
      // Add Headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add File
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print('API Multipart Error: $e');
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

  Future<http.Response> deleteRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('API Delete Error: $e');
      rethrow;
    }
  }

  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('API Put Error: $e');
      rethrow;
    }
  }
}

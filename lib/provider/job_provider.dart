import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class JobProvider extends ApiProvider {
  // Fetch all job circulars
  Future<http.Response> getJobCirculars() => getRequest('/job_circulars');

  // Fetch job details by ID
  Future<http.Response> getJobDetails(int id) => getRequest('/job_circulars/$id');
}

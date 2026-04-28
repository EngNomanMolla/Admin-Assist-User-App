import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class DashboardProvider extends ApiProvider {
  Future<http.Response> getDashboardData() => getRequest('/dashboard');
}

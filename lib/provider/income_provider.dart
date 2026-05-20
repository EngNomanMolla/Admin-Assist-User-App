import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class IncomeProvider extends ApiProvider {
  Future<http.Response> getIncomeCategories() => getRequest('/income_categories');

  Future<http.Response> createIncomeCategory(Map<String, dynamic> data) =>
      postRequest('/income_categories', data);

  Future<http.Response> updateIncomeCategory(String id, Map<String, dynamic> data) =>
      postRequest('/income_categories/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteIncomeCategory(String id) =>
      postRequest('/income_categories/$id', {'_method': 'DELETE'});

  Future<http.Response> getIncomeTransactions() => getRequest('/income_transactions');

  Future<http.Response> createIncomeTransaction(Map<String, dynamic> data) =>
      postRequest('/income_transactions', data);

  Future<http.Response> updateIncomeTransaction(String id, Map<String, dynamic> data) =>
      postRequest('/income_transactions/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteIncomeTransaction(String id) =>
      postRequest('/income_transactions/$id', {'_method': 'DELETE'});
}

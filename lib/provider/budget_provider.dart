import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class BudgetProvider extends ApiProvider {
  Future<http.Response> getBudgets({String? status}) =>
      getRequest('/budgets${status != null ? '?status=$status' : ''}');

  Future<http.Response> createBudget(Map<String, dynamic> data) =>
      postRequest('/budgets', data);

  Future<http.Response> updateBudget(String id, Map<String, dynamic> data) =>
      postRequest('/budgets/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteBudget(String id) =>
      postRequest('/budgets/$id', {'_method': 'DELETE'});
}

import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class BudgetProvider extends ApiProvider {
  Future<http.Response> getBudgets({
    String? status,
    int? month,
    int? year,
    int? page,
    int? perPage,
  }) {
    final Map<String, String> queryParams = {};
    if (status != null) queryParams['status'] = status;
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    return getRequest('/budgets${queryString.isNotEmpty ? '?$queryString' : ''}');
  }

  Future<http.Response> getBudgetSummary({
    required String status,
    int? month,
    int? year,
  }) {
    final Map<String, String> queryParams = {'status': status};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    return getRequest('/budgets/summary${queryString.isNotEmpty ? '?$queryString' : ''}');
  }

  Future<http.Response> createBudget(Map<String, dynamic> data) =>
      postRequest('/budgets', data);

  Future<http.Response> updateBudget(String id, Map<String, dynamic> data) =>
      postRequest('/budgets/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteBudget(String id) =>
      postRequest('/budgets/$id', {'_method': 'DELETE'});
}

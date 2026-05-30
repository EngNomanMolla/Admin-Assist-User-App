import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class ExpenseProvider extends ApiProvider {
  Future<http.Response> getExpenseCategories() => getRequest('/expense_categories');

  Future<http.Response> createExpenseCategory(Map<String, dynamic> data) =>
      postRequest('/expense_categories', data);

  Future<http.Response> updateExpenseCategory(String id, Map<String, dynamic> data) =>
      postRequest('/expense_categories/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteExpenseCategory(String id) =>
      postRequest('/expense_categories/$id', {'_method': 'DELETE'});

  Future<http.Response> getExpenseTransactions({int? page, int? perPage}) {
    final Map<String, String> queryParams = {};
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    return getRequest('/expense_transactions${queryString.isNotEmpty ? '?$queryString' : ''}');
  }

  Future<http.Response> createExpenseTransaction(Map<String, dynamic> data) =>
      postRequest('/expense_transactions', data);

  Future<http.Response> updateExpenseTransaction(String id, Map<String, dynamic> data) =>
      putRequest('/expense_transactions/$id', data);

  Future<http.Response> deleteExpenseTransaction(String id) =>
      postRequest('/expense_transactions/$id', {'_method': 'DELETE'});
}

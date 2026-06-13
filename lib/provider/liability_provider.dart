import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class LiabilityProvider extends ApiProvider {
  Future<http.Response> getLiabilityCategories() => getRequest('/liability_categories');

  Future<http.Response> createLiabilityCategory(Map<String, dynamic> data) =>
      postRequest('/liability_categories', data);

  Future<http.Response> updateLiabilityCategory(String id, Map<String, dynamic> data) =>
      postRequest('/liability_categories/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteLiabilityCategory(String id) =>
      postRequest('/liability_categories/$id', {'_method': 'DELETE'});

  Future<http.Response> getLiabilityTransactions({int? page, int? perPage}) {
    final Map<String, String> queryParams = {};
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    return getRequest('/liability_transactions${queryString.isNotEmpty ? '?$queryString' : ''}');
  }

  Future<http.Response> createLiabilityTransaction(Map<String, dynamic> data) =>
      postRequest('/liability_transactions', data);

  Future<http.Response> updateLiabilityTransaction(String id, Map<String, dynamic> data) =>
      putRequest('/liability_transactions/$id', data);

  Future<http.Response> deleteLiabilityTransaction(String id) =>
      postRequest('/liability_transactions/$id', {'_method': 'DELETE'});

  Future<http.Response> addLiabilityPayment(String transactionId, Map<String, dynamic> data) =>
      postRequest('/liability_transactions/$transactionId/add-payment', data);

  Future<http.Response> addLiabilityHistory(String transactionId, Map<String, dynamic> data) =>
      postRequest('/liability_transactions/$transactionId/add-history', data);

  Future<http.Response> getLiabilityPaymentHistory(String transactionId) =>
      getRequest('/liability_transactions/$transactionId/payment-history');

  Future<http.Response> getLiabilityHistory(String transactionId) =>
      getRequest('/liability_transactions/$transactionId/history');

  Future<http.Response> updateLiabilityHistory(String transactionId, String historyId, Map<String, dynamic> data) =>
      putRequest('/liability_transactions/$transactionId/history/$historyId', data);

  Future<http.Response> deleteLiabilityHistory(String transactionId, String historyId) =>
      deleteRequest('/liability_transactions/$transactionId/history/$historyId', {});
}

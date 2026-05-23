import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class WealthProvider extends ApiProvider {
  Future<http.Response> getAssetCategories() => getRequest('/asset_categories');

  Future<http.Response> createAssetCategory(Map<String, dynamic> data) =>
      postRequest('/asset_categories', data);

  Future<http.Response> updateAssetCategory(String id, Map<String, dynamic> data) =>
      postRequest('/asset_categories/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteAssetCategory(String id) =>
      postRequest('/asset_categories/$id', {'_method': 'DELETE'});

  Future<http.Response> getAssetTransactions() => getRequest('/asset_transactions');

  Future<http.Response> createAssetTransaction(Map<String, dynamic> data) =>
      postRequest('/asset_transactions', data);

  Future<http.Response> updateAssetTransaction(String id, Map<String, dynamic> data) =>
      postRequest('/asset_transactions/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteAssetTransaction(String id) =>
      postRequest('/asset_transactions/$id', {'_method': 'DELETE'});
}

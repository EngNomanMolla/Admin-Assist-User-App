import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends ApiProvider {
  Future<http.Response> getProducts(String categoryId) =>
      getRequest('/products?category_id=$categoryId');
}

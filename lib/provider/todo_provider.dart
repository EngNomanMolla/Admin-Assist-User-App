import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class TodoProvider extends ApiProvider {
  Future<http.Response> getTodos(String filter) => getRequest('/todos?filter=$filter');

  Future<http.Response> createTodo(Map<String, dynamic> data) =>
      postRequest('/todos', data);

  Future<http.Response> updateTodo(int id, Map<String, dynamic> data) =>
      postRequest('/todos/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deleteTodo(int id) =>
      postRequest('/todos/$id', {'_method': 'DELETE'});
}

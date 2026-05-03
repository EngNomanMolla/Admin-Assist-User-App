import 'package:flutter_widgets/provider/api_provider.dart';
import 'package:http/http.dart' as http;

class PaymentProvider extends ApiProvider {
  Future<http.Response> getPayments() => getRequest('/payment_reminders');

  Future<http.Response> createPayment(Map<String, dynamic> data) =>
      postRequest('/payment_reminders', data);

  Future<http.Response> updatePayment(int id, Map<String, dynamic> data) =>
      postRequest('/payment_reminders/$id', {...data, '_method': 'PUT'});

  Future<http.Response> deletePayment(int id) =>
      postRequest('/payment_reminders/$id', {'_method': 'DELETE'});

  Future<http.Response> addPayment(int reminderId, Map<String, dynamic> data) =>
      postRequest('/payment_reminders/$reminderId/add-payment', data);
}

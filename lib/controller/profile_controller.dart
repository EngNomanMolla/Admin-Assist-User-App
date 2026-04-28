import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Hardcoded data provided by the user
  final userData = {
    "name": "Noman Molla",
    "email": "mollanoman2017@gmail.com",
    "phone": "01784787878",
    "email_verified_at": "2026-04-28T10:17:40.000000Z",
    "status": "active",
  }.obs;

  // Formatting date for display
  String get verifiedDate {
    try {
      final date = DateTime.parse(userData['email_verified_at']!);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "N/A";
    }
  }
}

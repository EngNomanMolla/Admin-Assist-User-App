import 'package:get/get.dart';
import 'package:flutter_widgets/controller/authcontroller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

import 'package:get/get.dart';

import 'login_controller.dart';
import 'register_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(LoginController.new);
    Get.lazyPut<RegisterController>(RegisterController.new);
  }
}

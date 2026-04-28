import 'package:get/get.dart';

import 'write_letter_controller.dart';

class WriteLetterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WriteLetterController>(WriteLetterController.new);
  }
}

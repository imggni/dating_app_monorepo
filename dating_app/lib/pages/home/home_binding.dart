import 'package:get/get.dart';

import '../circle/circle_controller.dart';
import '../game/game_controller.dart';
import '../mine/mine_controller.dart';
import '../slow_chat/slow_chat_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }

    if (!Get.isRegistered<CircleController>()) {
      Get.lazyPut<CircleController>(() => CircleController(), fenix: true);
    }
    if (!Get.isRegistered<GameController>()) {
      Get.lazyPut<GameController>(() => GameController(), fenix: true);
    }
    if (!Get.isRegistered<SlowChatController>()) {
      Get.lazyPut<SlowChatController>(() => SlowChatController(), fenix: true);
    }
    if (!Get.isRegistered<MineController>()) {
      Get.lazyPut<MineController>(() => MineController(), fenix: true);
    }
  }
}

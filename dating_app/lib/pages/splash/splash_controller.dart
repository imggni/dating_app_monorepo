import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/app_storage_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final accepted = await AppStorageService.isPrivacyAccepted();
      if (!accepted) {
        final agreed = await _showPrivacyDialog();
        if (agreed != true) {
          Get.offAllNamed(AppRoutes.login);
          return;
        }
        await AppStorageService.setPrivacyAccepted(true);
      }

      final token = await AppStorageService.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool?> _showPrivacyDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('隐私保护提示'),
        content: const Text('我们会在你同意后初始化聊天、通知、图片、麦克风等能力。你可以在设置中查看隐私政策和权限说明。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('暂不同意'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('同意并继续'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

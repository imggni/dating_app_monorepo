import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  static void show(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  static void error(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withAlpha(200),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}

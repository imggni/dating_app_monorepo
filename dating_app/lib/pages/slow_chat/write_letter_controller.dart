import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/api_client.dart';
import '../../api/slow_chat_api.dart';
import '../../routes/app_routes.dart';

class WriteLetterController extends GetxController {
  final receiverIdController = Get.put(TextEditingController());
  final titleController = Get.put(TextEditingController());
  final contentController = Get.put(TextEditingController());
  final delayMinutes = 60.obs;
  final isAnonymous = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    receiverIdController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> sendLetter() async {
    final receiverId = receiverIdController.text.trim();
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (receiverId.isEmpty) {
      Get.snackbar('提示', '请输入接收者ID');
      return;
    }
    if (title.isEmpty) {
      Get.snackbar('提示', '请输入信件标题');
      return;
    }
    if (content.isEmpty) {
      Get.snackbar('提示', '请输入信件内容');
      return;
    }

    isLoading.value = true;
    try {
      final api = SlowChatApi(ApiClient().dio);
      await api.sendLetter({
        'receiverId': receiverId,
        'title': title,
        'content': content,
        'delayTime': delayMinutes.value,
        'isAnonymous': isAnonymous.value,
      });
      Get.snackbar('提示', '信件已发送');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      if (e is DioException && e.error != null) {
        Get.snackbar('发送失败', e.error.toString());
      } else {
        Get.snackbar('发送失败', '系统异常，请稍后再试');
      }
    } finally {
      isLoading.value = false;
    }
  }
}

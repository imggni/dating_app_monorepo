import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/services/app_storage_service.dart';
import '../../../core/utils/im_util.dart';
import '../../../core/utils/toast_util.dart';
import '../../../routes/app_routes.dart';
import '../../../api/api_client.dart';
import '../../../api/user_api.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final phone = phoneController.text;
    final password = passwordController.text;

    if (phone.length != 11 || password.length < 6) {
      ToastUtil.show('请输入正确的11位手机号和6位以上密码');
      return;
    }

    loading.value = true;

    try {
      final userApi = UserApi(ApiClient().dio);
      final response = await userApi.login({
        'phone': phone,
        'password': password,
      });

      final data = response['data'];
      final token = data?['token'] ?? data?['access_token'];
      if (data != null && token != null) {
        await AppStorageService.saveToken(token.toString());
        await ImUtil.loginIfPossible();
        Get.offAllNamed(AppRoutes.home);
      } else {
        ToastUtil.error('登录失败：无效的返回数据');
      }
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('系统异常，请稍后再试');
      }
    } finally {
      loading.value = false;
    }
  }
}

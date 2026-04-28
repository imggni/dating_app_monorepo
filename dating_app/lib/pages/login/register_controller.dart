import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_client.dart';
import '../../../api/user_api.dart';
import '../../../core/utils/toast_util.dart';

class RegisterController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final phone = phoneController.text;
    final password = passwordController.text;
    final nickname = nicknameController.text;

    if (phone.length != 11 || password.length < 6 || nickname.isEmpty) {
      ToastUtil.show('请正确填写11位手机号、6位以上密码和昵称');
      return;
    }

    loading.value = true;

    try {
      final userApi = UserApi(ApiClient().dio);
      final response = await userApi.register({
        'phone': phone,
        'password': password,
        'nickname': nickname,
      });

      final data = response['data'];
      if (data != null && (data['userId'] != null || data['id'] != null)) {
        ToastUtil.success('注册成功，请登录');
        Get.back();
      } else {
        ToastUtil.error('注册失败：无效的返回数据');
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

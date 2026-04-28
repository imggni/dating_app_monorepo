import 'package:dio/dio.dart';

import '../../api/api_client.dart';
import '../../api/im_api.dart';
import '../../api/im_api/tencent_im_sdk.dart';
import '../config/im_config.dart';
import '../services/app_storage_service.dart';
import 'toast_util.dart';

class ImUtil {
  const ImUtil._();

  static bool _sdkReady = false;

  static Future<void> initSdkIfNeeded() async {
    if (_sdkReady) return;
    await TencentImSdk.init(sdkAppId: ImConfig.sdkAppId);
    _sdkReady = true;
  }

  static Future<void> loginIfPossible() async {
    final token = await AppStorageService.getToken();
    if (token == null || token.isEmpty) return;

    await initSdkIfNeeded();

    try {
      final imApi = ImApi(ApiClient().dio);
      final response = await imApi.getUserSig();
      final data = response['data'];
      if (data == null) return;

      final userId = data['userId']?.toString();
      final userSig = data['userSig']?.toString();

      if (userId == null || userSig == null) return;
      await TencentImSdk.login(userId: userId, userSig: userSig);
    } catch (e) {
      // ApiClient 的拦截器已经处理了 DioException 的 Toast 提示
      if (e is! DioException) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ToastUtil.error('IM 登录失败: $msg');
      }
    }
  }
}

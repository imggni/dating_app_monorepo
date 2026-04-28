import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class TencentImSdk {
  const TencentImSdk._();

  static bool _initialized = false;

  static Future<void> init({required int sdkAppId}) async {
    if (_initialized) return;
    await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: sdkAppId,
      loglevel: LogLevelEnum.V2TIM_LOG_INFO,
      listener: V2TimSDKListener(),
    );
    _initialized = true;
  }

  static Future<void> login({
    required String userId,
    required String userSig,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager.login(
      userID: userId,
      userSig: userSig,
    );
    if (res.code != 0) {
      throw Exception(res.desc.isEmpty ? 'IM 登录失败' : res.desc);
    }
  }

  static Future<void> logout() async {
    await TencentImSDKPlugin.v2TIMManager.logout();
  }
}

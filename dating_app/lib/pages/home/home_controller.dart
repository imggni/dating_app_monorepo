import 'package:get/get.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import '../../core/models/app_models.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/utils/toast_util.dart';
import '../../routes/app_routes.dart';
import '../../api/api_client.dart';
import '../../api/im_api.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  final conversations = <ConversationItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      // 1. 先从后端拉取未读总数（作为兜底或同步）
      final imApi = ImApi(ApiClient().dio);
      final unreadRes = await imApi.getUnreadCount();
      final unreadData = unreadRes['data'];

      // 2. 从腾讯 IM SDK 获取真实会话列表
      final res = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .getConversationList(count: 20, nextSeq: '0');

      if (res.code == 0 && res.data != null) {
        final list = res.data!.conversationList ?? [];
        conversations.value =
            list
                .map((V2TimConversation? e) {
                  if (e == null) return null;
                  return ConversationItem(
                    id: e.userID ?? e.groupID ?? '',
                    title: e.showName ?? '未知会话',
                    lastMessage: e.lastMessage?.textElem?.text ?? '[消息]',
                    timeLabel: _formatTimestamp(e.lastMessage?.timestamp ?? 0),
                    unreadCount: e.unreadCount ?? 0,
                  );
                })
                .whereType<ConversationItem>()
                .toList();
      }

      // 如果 SDK 没数据，放一个 mock 兜底
      if (conversations.isEmpty && unreadData != null) {
        conversations.value = [
          ConversationItem(
            id: 'system',
            title: '系统通知',
            lastMessage: '欢迎来到 Dating App',
            timeLabel: '刚刚',
            unreadCount: unreadData['unreadCount'] ?? 0,
          ),
        ];
      }
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('获取会话失败: 系统异常');
      }
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    if (date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }

  void changeTab(int index) => currentIndex.value = index;

  Future<void> logout() async {
    await AppStorageService.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}

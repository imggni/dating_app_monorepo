import 'package:get/get.dart';

import '../../core/models/app_models.dart';
import '../../core/utils/toast_util.dart';
import '../../api/api_client.dart';
import '../../api/slow_chat_api.dart';

class SlowChatController extends GetxController {
  final letters = <LetterItem>[].obs;
  final isLoading = false.obs;
  final selectedTab = 'messages'.obs;
  final hasMore = true.obs;
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    fetchLetters();
  }

  Future<void> fetchLetters({bool refresh = true}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
    }
    if (!hasMore.value && !refresh) return;
    isLoading.value = true;
    try {
      final api = SlowChatApi(ApiClient().dio);
      final response = await api.getRooms(_page, 20);
      final data = response['data'];
      final list =
          (data?['messages'] as List?) ??
          (data?['items'] as List?) ??
          (data?['rooms'] as List?) ??
          const [];
      final mapped =
          list
              .map(
                (e) => LetterItem.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();
      letters.value = refresh ? mapped : [...letters, ...mapped];
      hasMore.value = data?['pagination']?['hasMore'] == true;
      _page++;
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('获取信件失败: 系统异常');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openLetter(String letterId) async {
    try {
      final api = SlowChatApi(ApiClient().dio);
      await api.openLetter(letterId);
      await fetchLetters();
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('开封失败: 系统异常');
      }
    }
  }

  Future<void> deleteLetter(String letterId) async {
    try {
      final api = SlowChatApi(ApiClient().dio);
      await api.deleteLetter(letterId);
      await fetchLetters();
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('删除失败: 系统异常');
      }
    }
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    fetchLetters();
  }

  Future<void> setAnonymous(String letterId, bool isAnonymous) async {
    try {
      final api = SlowChatApi(ApiClient().dio);
      await api.setAnonymous(letterId, {'isAnonymous': isAnonymous});
      await fetchLetters();
      ToastUtil.success('设置成功');
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('设置失败: 系统异常');
      }
    }
  }
}

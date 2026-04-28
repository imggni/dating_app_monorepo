import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/models/app_models.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/utils/toast_util.dart';
import '../../routes/app_routes.dart';
import '../../api/api_client.dart';
import '../../api/user_api.dart';

class MineController extends GetxController {
  final profile =
      const UserProfile(id: '', nickname: '加载中...', bio: '', tags: []).obs;
  final friends = <FriendItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchFriends();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final userApi = UserApi(ApiClient().dio);
      final response = await userApi.getProfile();
      final data = response['data'];

      if (data != null) {
        profile.value = UserProfile.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        Get.snackbar('获取个人信息失败', e.error.toString());
      } else {
        Get.snackbar('获取个人信息失败', '系统异常，请稍后再试');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final userApi = UserApi(ApiClient().dio);
      final response = await userApi.updateProfile(data);
      final profileData = response['data'];
      if (profileData != null) {
        profile.value = UserProfile.fromJson(
          Map<String, dynamic>.from(profileData),
        );
      }
      ToastUtil.success('资料已更新');
    } catch (e) {
      if (e is DioException && e.error != null) {
        ToastUtil.error(e.error.toString());
      } else {
        ToastUtil.error('更新失败，请稍后再试');
      }
    }
  }

  Future<void> fetchFriends() async {
    try {
      final userApi = UserApi(ApiClient().dio);
      final response = await userApi.getFriendList();
      final list = (response['data'] as List?) ?? const [];
      friends.value =
          list
              .map(
                (e) => FriendItem.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();
      await _refreshFriendOnlineStatus();
    } catch (e) {
      if (e is DioException && e.error != null) {
        ToastUtil.error(e.error.toString());
      }
    }
  }

  Future<void> sendFriendRequest(String friendId) async {
    if (friendId.trim().isEmpty) {
      ToastUtil.show('请输入用户ID');
      return;
    }
    try {
      final userApi = UserApi(ApiClient().dio);
      await userApi.sendFriendRequest({'friendId': friendId.trim()});
      ToastUtil.success('好友请求已发送');
    } catch (e) {
      if (e is DioException && e.error != null) {
        ToastUtil.error(e.error.toString());
      } else {
        ToastUtil.error('发送失败，请稍后再试');
      }
    }
  }

  Future<void> _refreshFriendOnlineStatus() async {
    final userApi = UserApi(ApiClient().dio);
    final updated = <FriendItem>[];
    for (final friend in friends) {
      try {
        final response = await userApi.getOnlineStatus(friend.id);
        final online = response['data']?['online'] == true;
        updated.add(
          FriendItem(
            id: friend.id,
            nickname: friend.nickname,
            avatar: friend.avatar,
            gender: friend.gender,
            online: online,
          ),
        );
      } catch (_) {
        updated.add(friend);
      }
    }
    friends.value = updated;
  }

  Future<void> remoteLogout() async {
    try {
      await UserApi(ApiClient().dio).logout();
    } catch (_) {
      // Local logout should still complete when the server session is already invalid.
    }
  }

  Future<void> logout() async {
    await remoteLogout();
    await AppStorageService.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}

import 'package:get/get.dart';

import '../../core/models/app_models.dart';
import '../../core/utils/toast_util.dart';
import '../../api/api_client.dart';
import '../../api/circle_api.dart';
import '../../api/common_api.dart';

class CircleController extends GetxController {
  final circles = <CircleItem>[].obs;
  final selectedCircleId = ''.obs;
  final posts = <CirclePost>[].obs;
  final comments = <CircleComment>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMorePosts = true.obs;
  final keyword = ''.obs;
  int _postPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchCircles();
  }

  Future<void> fetchCircles() async {
    isLoading.value = true;
    try {
      final api = CircleApi(ApiClient().dio);
      final response = await api.getCircleList(1, 20);
      final data = response['data'];
      final list =
          (data?['circles'] as List?) ?? (data?['list'] as List?) ?? const [];

      circles.value =
          list
              .map(
                (e) => CircleItem.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();

      if (circles.isNotEmpty) {
        selectedCircleId.value = circles.first.id;
        await fetchPosts(circleId: selectedCircleId.value, refresh: true);
      }
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('获取圈子失败: 系统异常');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPosts({
    required String circleId,
    bool refresh = false,
    String? searchKeyword,
  }) async {
    if (refresh) {
      _postPage = 1;
      hasMorePosts.value = true;
    }
    if (!hasMorePosts.value && !refresh) return;

    if (refresh) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    try {
      final api = CircleApi(ApiClient().dio);
      final activeKeyword = searchKeyword ?? keyword.value;
      final response =
          activeKeyword.isEmpty
              ? await api.getPostList(circleId, _postPage, 20)
              : await api.filterPosts(activeKeyword, '', _postPage, 20);
      final data = response['data'];
      final list =
          (data?['posts'] as List?) ?? (data?['list'] as List?) ?? const [];
      final topic =
          circles
              .firstWhere(
                (c) => c.id == circleId,
                orElse:
                    () => const CircleItem(id: '', name: '分享', description: ''),
              )
              .name;

      final mapped =
          list
              .map(
                (e) => CirclePost.fromJson(
                  Map<String, dynamic>.from(e as Map),
                  fallbackTopic: topic,
                ),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();
      posts.value = refresh ? mapped : [...posts, ...mapped];
      final pagination = data?['pagination'];
      hasMorePosts.value = pagination?['hasMore'] == true;
      _postPage++;
    } catch (e) {
      // ApiClient's interceptor already handles Toast for DioException
      if (e is! Exception) {
        ToastUtil.error('获取帖子失败: 系统异常');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> selectCircle(String circleId) async {
    selectedCircleId.value = circleId;
    keyword.value = '';
    await fetchPosts(circleId: circleId, refresh: true);
  }

  Future<void> searchPosts(String value) async {
    keyword.value = value.trim();
    await fetchPosts(circleId: selectedCircleId.value, refresh: true);
  }

  Future<void> publishPost({
    required String content,
    List<String> images = const [],
  }) async {
    if (selectedCircleId.value.isEmpty) {
      ToastUtil.show('请先选择圈子');
      return;
    }
    if (content.trim().isEmpty) {
      ToastUtil.show('请输入帖子内容');
      return;
    }
    try {
      final commonApi = CommonApi(ApiClient().dio);
      final filterResponse = await commonApi.filterSensitiveContent({
        'content': content.trim(),
        'type': 'text',
      });
      final filterData = filterResponse['data'];
      if (filterData?['isSensitive'] == true || filterData?['safe'] == false) {
        ToastUtil.error('内容包含敏感信息，请修改后再发布');
        return;
      }
      final api = CircleApi(ApiClient().dio);
      await api.publishPost({
        'circleId': selectedCircleId.value,
        'content': content.trim(),
        'images': images,
      });
      ToastUtil.success('发布成功');
      await fetchPosts(circleId: selectedCircleId.value, refresh: true);
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('发布失败: 系统异常');
      }
    }
  }

  Future<CirclePost?> fetchPostDetail(String postId) async {
    try {
      final api = CircleApi(ApiClient().dio);
      final response = await api.getPostDetail(postId);
      final data = response['data'];
      if (data == null) return null;
      return CirclePost.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('获取帖子详情失败: 系统异常');
      }
      return null;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final api = CircleApi(ApiClient().dio);
      final response = await api.likePost(postId);
      final likes = (response['data']?['likes'] as num?)?.toInt();
      posts.value =
          posts
              .map(
                (post) =>
                    post.id == postId
                        ? CirclePost(
                          id: post.id,
                          author: post.author,
                          topic: post.topic,
                          content: post.content,
                          likes: likes ?? post.likes + 1,
                          comments: post.comments,
                          circleId: post.circleId,
                          images: post.images,
                          isLiked: true,
                          createdAt: post.createdAt,
                        )
                        : post,
              )
              .toList();
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('点赞失败: 系统异常');
      }
    }
  }

  Future<void> fetchComments(String postId) async {
    try {
      final api = CircleApi(ApiClient().dio);
      final response = await api.getComments(postId, 1, 50);
      final list = (response['data']?['comments'] as List?) ?? const [];
      comments.value =
          list
              .map(
                (e) =>
                    CircleComment.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .where((e) => e.id.isNotEmpty)
              .toList();
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('获取评论失败: 系统异常');
      }
    }
  }

  Future<void> addComment(String postId, String content) async {
    if (content.trim().isEmpty) {
      ToastUtil.show('请输入评论内容');
      return;
    }
    try {
      final api = CircleApi(ApiClient().dio);
      await api.addComment(postId, {'content': content.trim()});
      await fetchComments(postId);
      await fetchPosts(circleId: selectedCircleId.value, refresh: true);
    } catch (e) {
      if (e is! Exception) {
        ToastUtil.error('评论失败: 系统异常');
      }
    }
  }
}

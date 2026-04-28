import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'circle_controller.dart';

class CircleView extends GetView<CircleController> {
  const CircleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('兴趣圈子'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.circlePublish),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh:
              () => controller.fetchPosts(
                circleId: controller.selectedCircleId.value,
                refresh: true,
              ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '搜索帖子或话题',
                ),
                onSubmitted: controller.searchPosts,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final circle in controller.circles)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(circle.name),
                          selected:
                              controller.selectedCircleId.value == circle.id,
                          onSelected: (_) => controller.selectCircle(circle.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (controller.isLoading.value && controller.posts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.posts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('暂无帖子')),
                )
              else
                ...controller.posts.map((post) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap:
                          () => Get.toNamed(
                            AppRoutes.circleDetail,
                            arguments: post.id,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Text(post.author.characters.first),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(post.author)),
                                Chip(label: Text('#${post.topic}')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(post.content),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => controller.likePost(post.id),
                                  icon: const Icon(Icons.thumb_up_alt_outlined),
                                  label: Text('${post.likes}'),
                                ),
                                TextButton.icon(
                                  onPressed:
                                      () => Get.toNamed(
                                        AppRoutes.circleDetail,
                                        arguments: post.id,
                                      ),
                                  icon: const Icon(Icons.mode_comment_outlined),
                                  label: Text('${post.comments}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              if (controller.hasMorePosts.value && controller.posts.isNotEmpty)
                OutlinedButton(
                  onPressed:
                      controller.isLoadingMore.value
                          ? null
                          : () => controller.fetchPosts(
                            circleId: controller.selectedCircleId.value,
                          ),
                  child: Text(
                    controller.isLoadingMore.value ? '加载中...' : '加载更多',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

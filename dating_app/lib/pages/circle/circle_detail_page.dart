import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/app_models.dart';
import 'circle_controller.dart';

class CircleDetailView extends StatefulWidget {
  const CircleDetailView({super.key});

  @override
  State<CircleDetailView> createState() => _CircleDetailViewState();
}

class _CircleDetailViewState extends State<CircleDetailView> {
  final CircleController controller = Get.find<CircleController>();
  final TextEditingController commentController = TextEditingController();
  CirclePost? post;
  bool isLoading = true;

  String get postId => Get.arguments?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final detail = await controller.fetchPostDetail(postId);
    await controller.fetchComments(postId);
    if (!mounted) return;
    setState(() {
      post = detail;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : post == null
              ? const Center(child: Text('帖子不存在'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(post!.author.characters.first),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(post!.author)),
                              Chip(label: Text('#${post!.topic}')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(post!.content),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => controller.likePost(post!.id),
                            icon: const Icon(Icons.thumb_up_alt_outlined),
                            label: Text('点赞 ${post!.likes}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('评论', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Obx(
                    () => Column(
                      children:
                          controller.comments.isEmpty
                              ? [const ListTile(title: Text('暂无评论'))]
                              : controller.comments
                                  .map(
                                    (comment) => Card(
                                      child: ListTile(
                                        title: Text(comment.author),
                                        subtitle: Text(comment.content),
                                        trailing: Text('赞 ${comment.likes}'),
                                      ),
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: '写下你的评论',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      await controller.addComment(
                        post!.id,
                        commentController.text,
                      );
                      commentController.clear();
                    },
                    child: const Text('发表评论'),
                  ),
                ],
              ),
    );
  }
}

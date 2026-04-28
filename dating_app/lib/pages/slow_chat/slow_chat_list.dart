import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'slow_chat_controller.dart';

class SlowChatView extends GetView<SlowChatController> {
  const SlowChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('慢社交')),
      body: Obx(() {
        if (controller.isLoading.value && controller.letters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.letters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('暂无慢消息', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchLetters(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('慢消息', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...controller.letters.map((letter) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      if (!letter.isOpened) controller.openLetter(letter.id);
                    },
                    leading: Icon(
                      letter.isOpened
                          ? Icons.mark_email_read_outlined
                          : Icons.mark_email_unread_outlined,
                      color: letter.isOpened ? Colors.grey : Colors.orange,
                    ),
                    title: Text(letter.title),
                    subtitle: Text(
                      '${letter.senderName} · ${letter.preview}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') _showDeleteDialog(letter.id);
                        if (value == 'anonymous') {
                          controller.setAnonymous(
                            letter.id,
                            !letter.isAnonymous,
                          );
                        }
                      },
                      itemBuilder:
                          (_) => [
                            PopupMenuItem(
                              value: 'anonymous',
                              child: Text(letter.isAnonymous ? '取消匿名' : '设为匿名'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                    ),
                  ),
                );
              }),
              if (controller.hasMore.value)
                OutlinedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () => controller.fetchLetters(refresh: false),
                  child: Text(controller.isLoading.value ? '加载中...' : '加载更多'),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.writeLetter),
        label: const Text('写信'),
        icon: const Icon(Icons.edit),
      ),
    );
  }

  void _showDeleteDialog(String letterId) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除信件'),
        content: const Text('确定要删除这封信件吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteLetter(letterId);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

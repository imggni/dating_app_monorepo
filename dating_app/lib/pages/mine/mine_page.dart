import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'mine_controller.dart';

class MineView extends GetView<MineController> {
  const MineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: Obx(() {
        final profile = controller.profile.value;
        return ListView(
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
                          child: Text(
                            profile.nickname.isEmpty
                                ? '我'
                                : profile.nickname.characters.first,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile.nickname,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(profile.onlineStatus ? '在线' : '离线'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(profile.bio.isEmpty ? '还没有填写个人简介' : profile.bio),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          profile.tags
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.editProfile),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('编辑资料'),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.people_outline),
                title: Text('好友 ${controller.friends.length}'),
                subtitle: const Text('好友列表、请求和在线状态'),
                children: [
                  if (controller.friends.isEmpty)
                    const ListTile(title: Text('暂无好友')),
                  ...controller.friends.map(
                    (friend) => ListTile(
                      leading: CircleAvatar(
                        child: Text(friend.nickname.characters.first),
                      ),
                      title: Text(friend.nickname),
                      subtitle: Text(friend.online ? '在线' : '离线'),
                      trailing: Text(friend.gender),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_outlined),
                    title: const Text('添加好友'),
                    onTap: () => _showFriendRequestDialog(controller),
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('设置与合规'),
                subtitle: const Text('隐私政策、用户协议、注销入口'),
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: controller.logout,
              child: const Text('退出登录'),
            ),
          ],
        );
      }),
    );
  }

  void _showFriendRequestDialog(MineController controller) {
    final friendIdController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('添加好友'),
        content: TextField(
          controller: friendIdController,
          decoration: const InputDecoration(labelText: '对方用户ID'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final friendId = friendIdController.text;
              Get.back();
              controller.sendFriendRequest(friendId);
            },
            child: const Text('发送请求'),
          ),
        ],
      ),
    );
  }
}

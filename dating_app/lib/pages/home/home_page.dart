import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../circle/circle_list.dart';
import '../game/game_room_page.dart';
import '../mine/mine_page.dart';
import '../slow_chat/slow_chat_list.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _ChatTab(controller: controller),
      const CircleView(),
      const GameView(),
      const SlowChatView(),
      const MineView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: '消息',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              label: '圈子',
            ),
            NavigationDestination(icon: Icon(Icons.draw_outlined), label: '游戏'),
            NavigationDestination(icon: Icon(Icons.mail_outline), label: '慢信'),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('即时通讯')),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.conversations.isEmpty) {
          return const Center(child: Text('暂无会话'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final item = controller.conversations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => Get.toNamed(AppRoutes.chatDetail, arguments: item),
                leading: CircleAvatar(child: Text(item.title.characters.first)),
                title: Text(item.title),
                subtitle: Text(
                  item.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.timeLabel),
                    if (item.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'game_controller.dart';
import '../../widgets/game/drawing_board.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('你画我猜')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '热门房间',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showCreateRoomDialog(controller),
                icon: const Icon(Icons.add),
                label: const Text('创建'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children:
                  controller.rooms
                      .map(
                        (room) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(room.name),
                            subtitle: Text(
                              '${room.players}/${room.maxPlayers}人 · ${room.status}',
                            ),
                            trailing: FilledButton(
                              onPressed: () => controller.joinRoom(room),
                              child: const Text('加入'),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              controller.selectedRoom.value == null
                  ? '实时画板预览'
                  : '房间：${controller.selectedRoom.value!.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          const AspectRatio(aspectRatio: 1.2, child: DrawingBoard()),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('画笔粗细 ${controller.strokeWidth.value.toStringAsFixed(0)}'),
                Slider(
                  min: 2,
                  max: 12,
                  value: controller.strokeWidth.value,
                  onChanged: (value) => controller.strokeWidth.value = value,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorButton(
                      color: const Color(0xFF7C4DFF),
                      controller: controller,
                    ),
                    _ColorButton(color: Colors.red, controller: controller),
                    _ColorButton(color: Colors.green, controller: controller),
                    _ColorButton(color: Colors.black, controller: controller),
                    OutlinedButton(
                      onPressed: controller.undoStroke,
                      child: const Text('撤销'),
                    ),
                    OutlinedButton(
                      onPressed: controller.clearBoard,
                      child: const Text('清空'),
                    ),
                    FilledButton(
                      onPressed: controller.startGame,
                      child: const Text('开始游戏'),
                    ),
                    FilledButton.tonal(
                      onPressed: controller.endRound,
                      child: const Text('结束回合'),
                    ),
                    if (controller.selectedRoom.value != null)
                      TextButton(
                        onPressed: controller.leaveRoom,
                        child: const Text('离开房间'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(GameController controller) {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('创建房间'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '房间名称'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = nameController.text;
              Get.back();
              controller.createRoom(name);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({required this.color, required this.controller});

  final Color color;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.brushColor.value = color,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

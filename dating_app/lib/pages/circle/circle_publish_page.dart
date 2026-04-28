import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'circle_controller.dart';

class CirclePublishView extends StatefulWidget {
  const CirclePublishView({super.key});

  @override
  State<CirclePublishView> createState() => _CirclePublishViewState();
}

class _CirclePublishViewState extends State<CirclePublishView> {
  final CircleController controller = Get.find<CircleController>();
  final TextEditingController contentController = TextEditingController();

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发布帖子')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => DropdownButtonFormField<String>(
              value:
                  controller.selectedCircleId.value.isEmpty
                      ? null
                      : controller.selectedCircleId.value,
              decoration: const InputDecoration(labelText: '选择圈子'),
              items:
                  controller.circles
                      .map(
                        (circle) => DropdownMenuItem(
                          value: circle.id,
                          child: Text(circle.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) controller.selectedCircleId.value = value;
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: '内容',
              hintText: '分享你的兴趣、故事或想法',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await controller.publishPost(content: contentController.text);
              if (mounted) Get.back();
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }
}

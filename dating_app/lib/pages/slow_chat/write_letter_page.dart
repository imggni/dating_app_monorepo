import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'write_letter_controller.dart';

class WriteLetterView extends GetView<WriteLetterController> {
  const WriteLetterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写信'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () => controller.sendLetter(),
              child:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('发送'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.receiverIdController,
              decoration: const InputDecoration(
                labelText: '接收者ID',
                hintText: '请输入接收者的用户ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                labelText: '信件标题',
                hintText: '给你的信取个标题吧',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  const Text('延迟时间：'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: controller.delayMinutes.value,
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30分钟')),
                      DropdownMenuItem(value: 60, child: Text('1小时')),
                      DropdownMenuItem(value: 180, child: Text('3小时')),
                      DropdownMenuItem(value: 360, child: Text('6小时')),
                      DropdownMenuItem(value: 720, child: Text('12小时')),
                      DropdownMenuItem(value: 1440, child: Text('24小时')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.delayMinutes.value = value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                title: const Text('匿名发送'),
                subtitle: const Text('接收者将无法看到你的身份'),
                value: controller.isAnonymous.value,
                onChanged: (value) => controller.isAnonymous.value = value,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.contentController,
              decoration: const InputDecoration(
                labelText: '信件内容',
                hintText: '在这里写下你想说的话...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              minLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}

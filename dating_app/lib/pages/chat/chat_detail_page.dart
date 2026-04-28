import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import '../../core/models/app_models.dart';

class ChatDetailController extends GetxController {
  final messages = <MessageItem>[].obs;
  final isLoading = false.obs;
  late ConversationItem conversation;

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationItem;
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      // 从腾讯 IM SDK 获取历史消息
      final res = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(userID: conversation.id, count: 20);

      if (res.code == 0 && res.data != null) {
        final list = res.data!;
        messages.value =
            list
                .map((V2TimMessage? e) {
                  if (e == null) return null;
                  return MessageItem(
                    id: e.msgID ?? '',
                    text: e.textElem?.text ?? '[消息]',
                    isMine: e.isSelf ?? false,
                  );
                })
                .whereType<MessageItem>()
                .toList();
      }
    } catch (e) {
      Get.snackbar('获取消息失败', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // 使用腾讯 IM SDK 创建并发送消息
      final createRes = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .createTextMessage(text: text.trim());

      if (createRes.code == 0 && createRes.data != null) {
        final res = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendMessage(
              id: createRes.data!.id!,
              receiver: conversation.id,
              groupID: '',
            );

        if (res.code == 0 && res.data != null) {
          final msg = res.data!;
          messages.insert(
            0,
            MessageItem(id: msg.msgID ?? '', text: text.trim(), isMine: true),
          );
        }
      }
    } catch (e) {
      Get.snackbar('发送失败', e.toString());
    }
  }
}

class ChatDetailView extends StatelessWidget {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());
    final inputController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(controller.conversation.title)),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final item = controller.messages[index];
                  return Align(
                    alignment:
                        item.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            item.isMine
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(item.text),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: const InputDecoration(hintText: '输入想说的话...'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      controller.sendMessage(inputController.text);
                      inputController.clear();
                    },
                    child: const Text('发送'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

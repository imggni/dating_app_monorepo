import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/app_storage_service.dart';
import 'mine_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MineController>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置与合规')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('隐私政策'),
              subtitle: const Text('查看个人信息与权限使用说明'),
              onTap:
                  () => _showDocument(
                    '隐私政策',
                    '我们会根据功能需要处理账号、资料、聊天、图片和设备权限信息。你可以在系统设置中撤回权限，或在本页申请注销账号。',
                  ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('用户协议'),
              subtitle: const Text('查看平台使用规则'),
              onTap:
                  () => _showDocument(
                    '用户协议',
                    '请遵守社区规范，不发布违法、骚扰、欺诈、侵权或不适宜内容。平台可对违规内容进行处理。',
                  ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text('账号注销'),
              subtitle: const Text('当前后端未提供删除账号接口，先提交注销提醒'),
              onTap: () => Get.snackbar('提示', '账号注销接口待后端开放后接入'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('权限说明'),
              subtitle: const Text('图片、相机、麦克风、通知均在使用时申请'),
              onTap:
                  () => _showDocument(
                    '权限说明',
                    '选择头像或发图时会申请相册/相机权限；发送语音或游戏语音时会申请麦克风权限；接收消息提醒时会申请通知权限。拒绝权限不会影响基础浏览功能。',
                  ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('撤回隐私同意'),
              subtitle: const Text('撤回后将退出登录，下次启动重新确认'),
              onTap: () async {
                await AppStorageService.setPrivacyAccepted(false);
                await controller.logout();
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              subtitle: const Text('清除本机登录状态并通知服务端下线'),
              onTap: controller.logout,
            ),
          ),
        ],
      ),
    );
  }

  void _showDocument(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: Get.back, child: const Text('知道了'))],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/app_models.dart';
import 'mine_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final MineController controller = Get.find<MineController>();
  late final TextEditingController nicknameController;
  late final TextEditingController avatarController;
  late final TextEditingController bioController;
  late final TextEditingController tagsController;
  late final TextEditingController genderController;
  late final TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    final profile = controller.profile.value;
    nicknameController = TextEditingController(text: profile.nickname);
    avatarController = TextEditingController(text: profile.avatar);
    bioController = TextEditingController(text: profile.bio);
    tagsController = TextEditingController(text: profile.tags.join(','));
    genderController = TextEditingController(text: profile.gender);
    ageController = TextEditingController(text: profile.age?.toString() ?? '');
  }

  @override
  void dispose() {
    nicknameController.dispose();
    avatarController.dispose();
    bioController.dispose();
    tagsController.dispose();
    genderController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nicknameController,
            decoration: const InputDecoration(labelText: '昵称'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: avatarController,
            decoration: const InputDecoration(labelText: '头像地址'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: genderController,
            decoration: const InputDecoration(labelText: '性别'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '年龄'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tagsController,
            decoration: const InputDecoration(labelText: '标签，用英文逗号分隔'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bioController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: '个人简介'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final nickname = nicknameController.text.trim();
              if (nickname.isEmpty) {
                Get.snackbar('提示', '昵称不能为空');
                return;
              }
              final age = int.tryParse(ageController.text.trim());
              await controller.updateProfile({
                'nickname': nickname,
                'avatar': avatarController.text.trim(),
                'gender': genderController.text.trim(),
                'age': age,
                'bio': bioController.text.trim(),
                'tags': UserProfile.parseTags(tagsController.text),
              });
              if (mounted) Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

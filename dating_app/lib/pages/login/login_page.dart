import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                '欢迎来到轻语交友',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text('手机号登录后可进入聊天、圈子、慢信与小游戏模块。'),
              const SizedBox(height: 24),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: '密码',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        controller.loading.value ? null : controller.login,
                    child: Text(controller.loading.value ? '登录中...' : '手机号登录'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: const Text('没有账号？立即注册'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

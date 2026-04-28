import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册新账号')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              TextField(
                controller: controller.nicknameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: '昵称',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.loading.value ? null : controller.register,
                    child: Text(controller.loading.value ? '提交中...' : '注册'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

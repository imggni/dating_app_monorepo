import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller;
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              child: Icon(Icons.favorite_rounded, size: 36),
            ),
            SizedBox(height: 16),
            Text('轻语交友'),
            SizedBox(height: 8),
            Text('匹配、倾诉、同好互动'),
          ],
        ),
      ),
    );
  }
}

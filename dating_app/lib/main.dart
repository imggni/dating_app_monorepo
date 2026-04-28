import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/config/app_config.dart';
import 'core/services/app_storage_service.dart';
import 'core/utils/im_util.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await AppStorageService.init();
  runApp(const DatingApp());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (await AppStorageService.isPrivacyAccepted()) {
      ImUtil.loginIfPossible();
    }
  });
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}

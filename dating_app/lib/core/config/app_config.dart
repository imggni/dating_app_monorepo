import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static int get imSdkAppId =>
      int.tryParse(dotenv.env['IM_SDK_APP_ID'] ?? '') ?? 1600138422;

  static String get appName => dotenv.env['APP_NAME'] ?? '轻语';

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}

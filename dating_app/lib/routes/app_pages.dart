import 'package:get/get.dart';

import '../pages/login/login_binding.dart';
import '../pages/login/login_page.dart';
import '../pages/login/register_page.dart';
import '../pages/circle/circle_detail_page.dart';
import '../pages/circle/circle_publish_page.dart';
import '../pages/chat/chat_detail_page.dart';
import '../pages/home/home_binding.dart';
import '../pages/home/home_page.dart';
import '../pages/mine/edit_profile_page.dart';
import '../pages/mine/setting_page.dart';
import '../pages/slow_chat/write_letter_binding.dart';
import '../pages/slow_chat/write_letter_page.dart';
import '../pages/splash/splash_binding.dart';
import '../pages/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.circleDetail,
      page: () => const CircleDetailView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.circlePublish,
      page: () => const CirclePublishView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.writeLetter,
      page: () => const WriteLetterView(),
      binding: WriteLetterBinding(),
    ),
  ];
}

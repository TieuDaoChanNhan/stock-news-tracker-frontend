import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/utils/app_pages.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/utils/theme_helper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeHelper.getLightTheme(),
      darkTheme: ThemeHelper.getDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

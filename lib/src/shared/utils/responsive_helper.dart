import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveHelper {
  static bool isMobile() => Get.width < 600;
  static bool isTablet() => Get.width >= 600 && Get.width < 1200;
  static bool isDesktop() => Get.width >= 1200;

  static double getResponsiveFontSize(double baseFontSize) {
    if (isMobile()) return baseFontSize;
    if (isTablet()) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  static EdgeInsets getResponsivePadding() {
    if (isMobile()) return const EdgeInsets.all(16);
    if (isTablet()) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static int getResponsiveGridCount() {
    if (isMobile()) return 1;
    if (isTablet()) return 2;
    return 3;
  }

  static double getResponsiveCardWidth() {
    if (isMobile()) return Get.width - 32;
    if (isTablet()) return (Get.width - 64) / 2;
    return (Get.width - 96) / 3;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop()) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveHelper.isTablet()) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/controllers/navigation_controller.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo NavigationController
    final navigationController = Get.put(NavigationController());
    
    return Scaffold(
      body: child,
      bottomNavigationBar: Obx(() {
        // ✅ BÂY GIỜ CÓ OBSERVABLE VARIABLE!
        return NavigationBar(
          selectedIndex: navigationController.selectedIndex, // ✅ Observable!
          onDestinationSelected: (index) => navigationController.updateIndex(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: 'Tin tức',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business),
              label: 'Công ty',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Watchlist',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Phân tích',
            ),
          ],
        );
      }),
    );
  }
}

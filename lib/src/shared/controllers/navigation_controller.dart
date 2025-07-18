import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';

class NavigationController extends GetxController {
  final _selectedIndex = 0.obs;
  
  int get selectedIndex => _selectedIndex.value;
  
  void updateIndex(int index) {
    _selectedIndex.value = index;
    _navigateToRoute(index);
  }
  
  void _navigateToRoute(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.dashboard);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.articles);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.companies);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.watchlist);
        break;
      case 4:
        Get.offAllNamed(AppRoutes.analytics);
        break;
    }
  }
  
  void setSelectedIndexByRoute(String route) {
    if (route.startsWith(AppRoutes.dashboard)) {
      _selectedIndex.value = 0;
    } else if (route.startsWith(AppRoutes.articles)) {
      _selectedIndex.value = 1;
    } else if (route.startsWith(AppRoutes.companies)) {
      _selectedIndex.value = 2;
    } else if (route.startsWith(AppRoutes.watchlist)) {
      _selectedIndex.value = 3;
    } else if (route.startsWith(AppRoutes.analytics)) {
      _selectedIndex.value = 4;
    } else {
      _selectedIndex.value = 0;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    // Set initial index based on current route
    setSelectedIndexByRoute(Get.currentRoute);
  }
}

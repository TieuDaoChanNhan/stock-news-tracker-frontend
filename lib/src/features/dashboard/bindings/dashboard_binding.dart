import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
  }
}

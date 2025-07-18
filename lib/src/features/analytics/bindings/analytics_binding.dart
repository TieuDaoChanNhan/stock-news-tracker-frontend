import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/analytics/controllers/analytics_controller.dart';

class AnalyticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnalyticsController());
  }
}

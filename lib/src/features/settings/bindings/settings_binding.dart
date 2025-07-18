import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/settings/controllers/settings_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

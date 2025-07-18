import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/companies/controllers/companies_controller.dart';

class CompaniesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompaniesController());
  }
}

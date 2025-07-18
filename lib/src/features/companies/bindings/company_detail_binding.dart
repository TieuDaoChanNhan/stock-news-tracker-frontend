import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/companies/controllers/company_detail_controller.dart';

class CompanyDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompanyDetailController());
  }
}

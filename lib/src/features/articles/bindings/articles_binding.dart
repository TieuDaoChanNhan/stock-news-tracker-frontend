import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/articles/controllers/articles_controller.dart';

class ArticlesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArticlesController());
  }
}

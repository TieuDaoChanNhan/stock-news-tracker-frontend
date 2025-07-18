import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/articles/controllers/article_detail_controller.dart';

class ArticleDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArticleDetailController());
  }
}

import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/watchlist/controllers/watchlist_controller.dart';

class WatchlistBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WatchlistController());
  }
}

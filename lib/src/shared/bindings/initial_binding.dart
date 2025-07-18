import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/services/dio_client.dart';
import 'package:stock_tracker_app/src/shared/services/articles_api_service.dart';
import 'package:stock_tracker_app/src/shared/services/ai_analysis_api_service.dart'; // ✅ THÊM
import 'package:stock_tracker_app/src/shared/services/companies_api_service.dart';
import 'package:stock_tracker_app/src/shared/services/watchlist_api_service.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/companies_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/watchlist_repository.dart';
import 'package:stock_tracker_app/src/shared/controllers/navigation_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // 🎯 Core UI Controllers
    Get.lazyPut(() => NavigationController(), fenix: true);
    
    // 🔧 Core Dependencies
    Get.lazyPut(() => DioClient.createDio(), fenix: true);

    // 🌐 API Services
    Get.lazyPut(() => ArticlesApiService(Get.find()), fenix: true);
    Get.lazyPut(() => AIAnalysisApiService(Get.find()), fenix: true); // ✅ THÊM
    Get.lazyPut(() => CompaniesApiService(Get.find()), fenix: true);
    Get.lazyPut(() => WatchlistApiService(Get.find()), fenix: true);

    // 📁 Repositories
    Get.lazyPut(() => ArticlesRepository(Get.find(), Get.find()), fenix: true); // ✅ SỬA: 2 services
    Get.lazyPut(() => CompaniesRepository(Get.find()), fenix: true);
    Get.lazyPut(() => WatchlistRepository(Get.find()), fenix: true);

    print("✅ InitialBinding: Tất cả dependencies đã được inject");
  }
}

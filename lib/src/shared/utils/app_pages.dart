import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/dashboard/dashboard_screen.dart';
import 'package:stock_tracker_app/src/features/articles/articles_list_screen.dart';
import 'package:stock_tracker_app/src/features/articles/article_detail_screen.dart';
import 'package:stock_tracker_app/src/features/companies/companies_list_screen.dart';
import 'package:stock_tracker_app/src/features/companies/company_detail_screen.dart';
import 'package:stock_tracker_app/src/features/watchlist/watchlist_screen.dart';
import 'package:stock_tracker_app/src/features/analytics/analytics_screen.dart';
import 'package:stock_tracker_app/src/features/settings/settings_screen.dart';

// Bindings
import 'package:stock_tracker_app/src/features/dashboard/bindings/dashboard_binding.dart';
import 'package:stock_tracker_app/src/features/articles/bindings/articles_binding.dart';
import 'package:stock_tracker_app/src/features/articles/bindings/article_detail_binding.dart';
import 'package:stock_tracker_app/src/features/companies/bindings/companies_binding.dart';
import 'package:stock_tracker_app/src/features/companies/bindings/company_detail_binding.dart';
import 'package:stock_tracker_app/src/features/watchlist/bindings/watchlist_binding.dart';
import 'package:stock_tracker_app/src/features/analytics/bindings/analytics_binding.dart';
import 'package:stock_tracker_app/src/features/settings/bindings/settings_binding.dart';

import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.dashboard;

  static final routes = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.articles,
      page: () => const ArticlesListScreen(),
      binding: ArticlesBinding(),
    ),
    GetPage(
      name: AppRoutes.articleDetail,
      page: () => const ArticleDetailScreen(),
      binding: ArticleDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.companies,
      page: () => const CompaniesListScreen(),
      binding: CompaniesBinding(),
    ),
    GetPage(
      name: AppRoutes.companyDetail,
      page: () => const CompanyDetailScreen(),
      binding: CompanyDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.watchlist,
      page: () => const WatchlistScreen(),
      binding: WatchlistBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsScreen(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}

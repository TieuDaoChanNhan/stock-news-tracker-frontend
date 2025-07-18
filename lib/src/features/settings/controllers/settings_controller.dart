import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/article_model.dart';
import 'package:stock_tracker_app/src/shared/models/watchlist_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/companies_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/watchlist_repository.dart';

class SettingsController extends GetxController {
  final ArticlesRepository _articlesRepository = Get.find<ArticlesRepository>();
  final CompaniesRepository _companiesRepository = Get.find<CompaniesRepository>();
  final WatchlistRepository _watchlistRepository = Get.find<WatchlistRepository>();

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // System stats
  final _systemStats = <String, dynamic>{}.obs;
  final _crawlSources = <CrawlSource>[].obs;

  // App preferences
  final _isDarkMode = false.obs;
  final _enableNotifications = true.obs;
  final _autoRefresh = true.obs;
  final _refreshInterval = 15.obs; // minutes

  // Getters
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Map<String, dynamic> get systemStats => _systemStats.value;
  List<CrawlSource> get crawlSources => _crawlSources.value;
  bool get isDarkMode => _isDarkMode.value;
  bool get enableNotifications => _enableNotifications.value;
  bool get autoRefresh => _autoRefresh.value;
  int get refreshInterval => _refreshInterval.value;

  @override
  void onInit() {
    super.onInit();
    loadSettingsData();
  }

  Future<void> loadSettingsData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await Future.wait([
        _loadSystemStats(),
        _loadCrawlSources(),
      ]);

    } catch (e) {
      _errorMessage.value = 'Failed to load settings: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadSystemStats() async {
    try {
      // Load các thống kê hệ thống
      final articlesCount = await _articlesRepository.getArticlesCount();
      final dashboardData = await _companiesRepository.getDashboardOverview();
      final watchlistItems = await _watchlistRepository.getWatchlist();

      _systemStats.value = {
        'total_articles': articlesCount['total_articles'] ?? 0,
        'total_companies': dashboardData.totalCompanies,
        'companies_with_data': dashboardData.companiesWithData,
        'api_usage_today': dashboardData.apiUsageToday,
        'api_limit': dashboardData.apiLimit,
        'watchlist_items': watchlistItems.length,
        'last_updated': DateTime.now(),
      };
    } catch (e) {
      print('Error loading system stats: $e');
    }
  }

  Future<void> _loadCrawlSources() async {
    try {
      final sources = await _watchlistRepository.getCrawlSources();
      _crawlSources.value = sources;
    } catch (e) {
      print('Error loading crawl sources: $e');
    }
  }

  // App preferences methods
  void toggleDarkMode(bool value) {
    _isDarkMode.value = value;
    // Implement theme switching logic
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotifications(bool value) {
    _enableNotifications.value = value;
    // Implement notification toggle logic
  }

  void toggleAutoRefresh(bool value) {
    _autoRefresh.value = value;
    // Implement auto refresh logic
  }

  void setRefreshInterval(int minutes) {
    _refreshInterval.value = minutes;
    // Implement refresh interval logic
  }

  // Crawl source management
  Future<void> toggleCrawlSource(int sourceId, bool isActive) async {
    try {
      await _watchlistRepository.updateCrawlSource(
        sourceId, 
        {'is_active': isActive}
      );
      
      // Update local state
      final index = _crawlSources.indexWhere((source) => source.id == sourceId);
      if (index != -1) {
        _crawlSources[index] = CrawlSource(
          id: _crawlSources[index].id,
          name: _crawlSources[index].name,
          url: _crawlSources[index].url,
          articleContainerSelector: _crawlSources[index].articleContainerSelector,
          titleSelector: _crawlSources[index].titleSelector,
          linkSelector: _crawlSources[index].linkSelector,
          summarySelector: _crawlSources[index].summarySelector,
          dateSelector: _crawlSources[index].dateSelector,
          isActive: isActive,
          lastCrawledAt: _crawlSources[index].lastCrawledAt,
          createdAt: _crawlSources[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _crawlSources.refresh();
      }

      Get.snackbar(
        'Thành công',
        'Đã ${isActive ? "kích hoạt" : "tạm dừng"} nguồn crawl',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật nguồn crawl: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // System actions
  Future<void> clearCache() async {
    try {
      // Implement cache clearing logic
      Get.snackbar(
        'Thành công',
        'Đã xóa cache hệ thống',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa cache: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> exportData() async {
    try {
      // Implement data export logic
      Get.snackbar(
        'Thông báo',
        'Tính năng xuất dữ liệu sẽ có trong phiên bản tới',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xuất dữ liệu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshSettings() async {
    await loadSettingsData();
  }

  // Computed properties
  List<CrawlSource> get activeSources {
    return _crawlSources.where((source) => source.isActive).toList();
  }

  List<CrawlSource> get inactiveSources {
    return _crawlSources.where((source) => !source.isActive).toList();
  }

  double get apiUsagePercentage {
    final usage = _systemStats['api_usage_today'] ?? 0;
    final limit = _systemStats['api_limit'] ?? 250;
    return limit > 0 ? (usage / limit) * 100 : 0;
  }

  String get systemHealthStatus {
    final apiUsage = apiUsagePercentage;
    final activeSourcesCount = activeSources.length;
    
    if (apiUsage > 90) return 'Cảnh báo';
    if (activeSourcesCount == 0) return 'Lỗi';
    return 'Tốt';
  }
}

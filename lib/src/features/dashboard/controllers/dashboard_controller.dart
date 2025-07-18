import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/article_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/models/dashboard_model.dart';
import 'package:stock_tracker_app/src/shared/models/watchlist_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/companies_repository.dart';
import 'package:stock_tracker_app/src/shared/repositories/watchlist_repository.dart';

class DashboardController extends GetxController {
  final ArticlesRepository _articlesRepository = Get.find<ArticlesRepository>();
  final CompaniesRepository _companiesRepository = Get.find<CompaniesRepository>();
  final WatchlistRepository _watchlistRepository = Get.find<WatchlistRepository>();

  // Observable states
  final _recentArticles = <ArticleWithAnalysis>[].obs;
  final _highImpactArticles = <ArticleWithAnalysis>[].obs;
  final _dashboardData = Rxn<DashboardData>();
  final _watchlistItems = <WatchlistItem>[].obs;
  final _articlesCount = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  List<ArticleWithAnalysis> get recentArticles => _recentArticles.value;
  List<ArticleWithAnalysis> get highImpactArticles => _highImpactArticles.value;
  DashboardData? get dashboardData => _dashboardData.value;
  List<WatchlistItem> get watchlistItems => _watchlistItems.value;
  int get articlesCount => _articlesCount.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Load tất cả data song song
      await Future.wait([
        _loadRecentArticles(),
        _loadCompanyDashboard(),
        _loadWatchlistItems(),
        _loadArticlesCount(),
      ]);

    } catch (e) {
      _errorMessage.value = 'Failed to load dashboard data: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadRecentArticles() async {
    try {
      // ✅ SỬA: Fetch articles with analysis
      final articles = await _articlesRepository.getArticlesWithAnalysis(skip: 0, limit: 10);
      _recentArticles.value = articles;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _loadHighImpactArticles() async {
    try {
      final articles = await _articlesRepository.getHighImpactArticles(minImpact: 0.7);
      _highImpactArticles.value = articles;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _loadCompanyDashboard() async {
    try {
      final dashboard = await _companiesRepository.getDashboardOverview();
      _dashboardData.value = dashboard;
    } catch (e) {
      print('Failed to load company dashboard: $e');
    }
  }

  Future<void> _loadWatchlistItems() async {
    try {
      final items = await _watchlistRepository.getWatchlist();
      _watchlistItems.value = items;
    } catch (e) {
      print('Failed to load watchlist: $e');
    }
  }

  Future<void> _loadArticlesCount() async {
    try {
      final countData = await _articlesRepository.getArticlesCount();
      _articlesCount.value = countData['total_articles'] ?? 0;
    } catch (e) {
      print('Failed to load articles count: $e');
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Analytics getters
  Map<String, int> get articlesByCategory {
    final categoryCount = <String, int>{};
    for (final article in _recentArticles) {
      final category = article.aiAnalysis?.category ?? 'Khác';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Map<String, int> get articlesBySentiment {
    final sentimentCount = <String, int>{};
    for (final article in _recentArticles) {
      final sentiment = article.aiAnalysis?.sentimentText ?? 'Không rõ';
      sentimentCount[sentiment] = (sentimentCount[sentiment] ?? 0) + 1;
    }
    return sentimentCount;
  }

  double get averageSentiment {
    final articlesWithSentiment = _recentArticles
        .where((article) => article.aiAnalysis?.sentimentScore != null)
        .toList();
    
    if (articlesWithSentiment.isEmpty) return 0.0;
    
    final total = articlesWithSentiment
        .map((article) => article.aiAnalysis!.sentimentScore!)
        .reduce((a, b) => a + b);
    
    return total / articlesWithSentiment.length;
  }

  String get sentimentTrend {
    if (averageSentiment > 0.1) return 'Tích cực';
    if (averageSentiment < -0.1) return 'Tiêu cực';
    return 'Trung tính';
  }
}

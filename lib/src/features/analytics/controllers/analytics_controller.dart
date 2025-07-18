import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class AnalyticsController extends GetxController {
  final ArticlesRepository _repository = Get.find<ArticlesRepository>();

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _selectedTimeRange = 'week'.obs;

  // ✅ SỬA: Sử dụng ArticleWithAnalysis
  final _categoryDistribution = <String, int>{}.obs;
  final _sentimentTrends = <String, double>{}.obs;
  final _impactAnalysis = <String, int>{}.obs;
  final _highImpactArticles = <ArticleWithAnalysis>[].obs;
  final _allArticles = <ArticleWithAnalysis>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get selectedTimeRange => _selectedTimeRange.value;
  Map<String, int> get categoryDistribution => _categoryDistribution.value;
  Map<String, double> get sentimentTrends => _sentimentTrends.value;
  Map<String, int> get impactAnalysis => _impactAnalysis.value;
  List<ArticleWithAnalysis> get highImpactArticles => _highImpactArticles.value;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await Future.wait([
        _loadAllArticles(),
        _loadHighImpactArticles(),
      ]);

      _calculateAnalytics();
    } catch (e) {
      _errorMessage.value = 'Failed to load analytics: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadAllArticles() async {
    // ✅ SỬA: Fetch articles with analysis
    final articles = await _repository.getArticlesWithAnalysis(skip: 0, limit: 100);
    _allArticles.value = articles;
  }

  Future<void> _loadHighImpactArticles() async {
    // ✅ SỬA: Return type đúng
    final highImpact = await _repository.getHighImpactArticles(minImpact: 0.7);
    _highImpactArticles.value = highImpact;
  }

  void _calculateAnalytics() {
    _calculateCategoryDistribution();
    _calculateSentimentTrends();
    _calculateImpactAnalysis();
  }

  void _calculateCategoryDistribution() {
    final distribution = <String, int>{};
    
    for (final articleWithAnalysis in _allArticles) {
      // ✅ SỬA: Access AI analysis từ ArticleWithAnalysis
      final category = articleWithAnalysis.aiAnalysis?.category ?? 'Không rõ';
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    
    _categoryDistribution.value = distribution;
  }

  void _calculateSentimentTrends() {
    final sentimentData = <String, List<double>>{
      'Tích cực': [],
      'Trung tính': [],
      'Tiêu cực': [],
    };

    for (final articleWithAnalysis in _allArticles) {
      // ✅ SỬA: Access sentiment từ AI analysis
      final sentiment = articleWithAnalysis.aiAnalysis?.sentimentScore;
      if (sentiment != null) {
        if (sentiment > 0.1) {
          sentimentData['Tích cực']!.add(sentiment);
        } else if (sentiment < -0.1) {
          sentimentData['Tiêu cực']!.add(sentiment.abs());
        } else {
          sentimentData['Trung tính']!.add(0.5);
        }
      }
    }

    final trends = <String, double>{};
    sentimentData.forEach((key, values) {
      if (values.isNotEmpty) {
        trends[key] = values.reduce((a, b) => a + b) / values.length;
      } else {
        trends[key] = 0.0;
      }
    });

    _sentimentTrends.value = trends;
  }

  void _calculateImpactAnalysis() {
    final impactData = <String, int>{
      'Cao': 0,
      'Trung bình': 0,
      'Thấp': 0,
    };

    for (final articleWithAnalysis in _allArticles) {
      // ✅ SỬA: Access impact từ AI analysis
      final impact = articleWithAnalysis.aiAnalysis?.impactScore;
      if (impact != null) {
        if (impact >= 0.7) {
          impactData['Cao'] = impactData['Cao']! + 1;
        } else if (impact >= 0.4) {
          impactData['Trung bình'] = impactData['Trung bình']! + 1;
        } else {
          impactData['Thấp'] = impactData['Thấp']! + 1;
        }
      }
    }

    _impactAnalysis.value = impactData;
  }

  void changeTimeRange(String timeRange) {
    _selectedTimeRange.value = timeRange;
    _calculateAnalytics();
  }

  Future<void> refreshAnalytics() async {
    await loadAnalyticsData();
  }

  // Getters cho chart data
  List<double> get categoryChartData {
    return _categoryDistribution.values.map((e) => e.toDouble()).toList();
  }

  List<String> get categoryLabels {
    return _categoryDistribution.keys.toList();
  }

  List<double> get sentimentChartData {
    return _sentimentTrends.values.toList();
  }

  List<String> get sentimentLabels {
    return _sentimentTrends.keys.toList();
  }

  // Summary statistics
  int get totalArticlesAnalyzed => _allArticles.length;
  
  double get averageSentiment {
    final articlesWithSentiment = _allArticles
        .where((a) => a.aiAnalysis?.sentimentScore != null)
        .toList();
    
    if (articlesWithSentiment.isEmpty) return 0.0;
    
    final total = articlesWithSentiment
        .map((a) => a.aiAnalysis!.sentimentScore!)
        .reduce((a, b) => a + b);
    
    return total / articlesWithSentiment.length;
  }

  double get averageImpact {
    final articlesWithImpact = _allArticles
        .where((a) => a.aiAnalysis?.impactScore != null)
        .toList();
    
    if (articlesWithImpact.isEmpty) return 0.0;
    
    final total = articlesWithImpact
        .map((a) => a.aiAnalysis!.impactScore!)
        .reduce((a, b) => a + b);
    
    return total / articlesWithImpact.length;
  }

  String get dominantCategory {
    if (_categoryDistribution.isEmpty) return 'N/A';
    
    return _categoryDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

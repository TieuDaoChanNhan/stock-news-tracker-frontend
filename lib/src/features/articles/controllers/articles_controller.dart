import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';

class ArticlesController extends GetxController {
  final ArticlesRepository _repository = Get.find<ArticlesRepository>();

  // ✅ SỬA: Sử dụng ArticleWithAnalysis
  final _articles = <ArticleWithAnalysis>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _hasMore = true.obs;
  
  // Filter states
  final _selectedCategory = Rxn<String>();
  final _showHighImpactOnly = false.obs;
  final _showSearchResult = false.obs;

  // Pagination
  final _currentPage = 0.obs;
  final int _limit = 20;
  final _searchValue = Rxn<String>();

  // Getters
  List<ArticleWithAnalysis> get articles => _articles.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMore => _hasMore.value;
  String? get selectedCategory => _selectedCategory.value;
  bool get showHighImpactOnly => _showHighImpactOnly.value;

  @override
  void onInit() {
    super.onInit();
    loadArticles();
  }

  Future<void> loadArticles({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 0;
        _hasMore.value = true;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      List<ArticleWithAnalysis> result;

      // Apply filters
      if (_showHighImpactOnly.value) {
        result = await _repository.getHighImpactArticles();
      } else if (_selectedCategory.value != null) {
        result = await _repository.getArticlesByCategory(_selectedCategory.value!);
      } else {
        // ✅ SỬA: Fetch articles with analysis
        result = await _repository.getArticlesWithAnalysis(
          skip: _currentPage.value * _limit,
          limit: _limit,
        );
      }

      if (refresh) {
        _articles.value = result;
      } else {
        _articles.addAll(result);
      }

      // ✅ SỬA: Search trong title của article
      if (_showSearchResult.value) {
        _articles.value = _articles.where((articleWithAnalysis) => 
          articleWithAnalysis.article.title.toLowerCase().contains(_searchValue.value?.toLowerCase() ?? '')
        ).toList();
      }

      _hasMore.value = result.length == _limit;
      _currentPage.value++;
    } catch (e) {
      _errorMessage.value = 'Failed to load articles: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshArticles() async {
    await loadArticles(refresh: true);
  }

  Future<void> loadMoreArticles() async {
    if (!_hasMore.value || _isLoading.value) return;
    await loadArticles();
  }

  void filterByCategory(String? category) {
    _selectedCategory.value = category;
    _showHighImpactOnly.value = false;
    _showSearchResult.value = false;
    loadArticles(refresh: true);
  }

  void filterBySearch(String? value) {
    _showSearchResult.value = value != null && value.isNotEmpty;
    _selectedCategory.value = null;
    _showHighImpactOnly.value = false;
    _searchValue.value = value;
    loadArticles(refresh: true);
  }

  void toggleHighImpactFilter() {
    _showHighImpactOnly.value = !_showHighImpactOnly.value;
    _selectedCategory.value = null;
    _showSearchResult.value = false;
    loadArticles(refresh: true);
  }

  void clearFilters() {
    _selectedCategory.value = null;
    _showHighImpactOnly.value = false;
    _showSearchResult.value = false;
    _searchValue.value = null;
    loadArticles(refresh: true);
  }

  // ✅ SỬA: Lấy categories từ AI analysis
  List<String> get availableCategories {
    final categories = articles
        .where((articleWithAnalysis) => articleWithAnalysis.aiAnalysis?.category != null)
        .map((articleWithAnalysis) => articleWithAnalysis.aiAnalysis!.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}

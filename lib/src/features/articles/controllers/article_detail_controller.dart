import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/ai_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/articles_repository.dart';

class ArticleDetailController extends GetxController {
  final ArticlesRepository _repository = Get.find<ArticlesRepository>();

  // ✅ SỬA: Sử dụng ArticleWithAnalysis
  final _articleWithAnalysis = Rxn<ArticleWithAnalysis>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  ArticleWithAnalysis? get articleWithAnalysis => _articleWithAnalysis.value;
  // Convenience getters
  Article? get article => _articleWithAnalysis.value?.article;
  AIAnalysis? get aiAnalysis => _articleWithAnalysis.value?.aiAnalysis;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    final articleIdStr = Get.parameters['id'];
    if (articleIdStr != null) {
      loadArticle(int.parse(articleIdStr));
    }
  }

  Future<void> loadArticle(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // ✅ SỬA: Fetch article with analysis từ repository
      final result = await _repository.getArticleWithAnalysis(id);
      _articleWithAnalysis.value = result;
      
    } catch (e) {
      _errorMessage.value = 'Failed to load article: $e';
    } finally {
      _isLoading.value = false;
    }
  }
}

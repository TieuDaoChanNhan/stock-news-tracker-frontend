import 'package:stock_tracker_app/src/shared/models/article_model.dart';
import 'package:stock_tracker_app/src/shared/models/ai_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/services/articles_api_service.dart';
import 'package:stock_tracker_app/src/shared/services/ai_analysis_api_service.dart';

class ArticlesRepository {
  final ArticlesApiService _articlesApiService;
  final AIAnalysisApiService _aiAnalysisApiService;

  ArticlesRepository(this._articlesApiService, this._aiAnalysisApiService);

  // ✅ SỬA: Method fetch articles with analysis
  Future<List<ArticleWithAnalysis>> getArticlesWithAnalysis({
    int skip = 0, 
    int limit = 20
  }) async {
    // 1. Fetch articles first - trả về List<Article>
    final articles = await _articlesApiService.fetchArticles(skip: skip, limit: limit);
    
    // 2. Fetch AI analysis for each article
    List<ArticleWithAnalysis> articlesWithAnalysis = [];
    
    // ✅ SỬA: articles đã là List<Article>, không cần Article.fromJson
    for (final article in articles) {
      try {
        final aiAnalysis = await _aiAnalysisApiService.getAIAnalysisForArticle(article.id);
        articlesWithAnalysis.add(ArticleWithAnalysis(
          article: article,
          aiAnalysis: aiAnalysis,
        ));
      } catch (e) {
        // Nếu không fetch được AI analysis, vẫn thêm article
        articlesWithAnalysis.add(ArticleWithAnalysis(
          article: article,
          aiAnalysis: null,
        ));
      }
    }
    
    return articlesWithAnalysis;
  }

  Future<List<ArticleWithAnalysis>> getHighImpactArticles({
    double minImpact = 0.7,
  }) async {
    return await _aiAnalysisApiService.getHighImpactArticles(minImpact: minImpact);
  }

  // ✅ SỬA: Method fetch by category
  Future<List<ArticleWithAnalysis>> getArticlesByCategory(String category) async {
    return await _aiAnalysisApiService.getArticlesByCategory(category);
  }

  // ✅ SỬA: Method fetch single article with analysis
  Future<ArticleWithAnalysis?> getArticleWithAnalysis(int articleId) async {
    try {
      // fetchArticleById trả về Article, không phải Map
      final article = await _articlesApiService.fetchArticleById(articleId);
      
      final aiAnalysis = await _aiAnalysisApiService.getAIAnalysisForArticle(articleId);
      
      return ArticleWithAnalysis(
        article: article, // ✅ SỬA: Không cần Article.fromJson
        aiAnalysis: aiAnalysis,
      );
    } catch (e) {
      throw Exception('Failed to load article with analysis: $e');
    }
  }

  // ✅ SỬA: Basic methods - sửa kiểu trả về cho đúng với service
  Future<List<Article>> getArticles({int skip = 0, int limit = 20}) async {
    return await _articlesApiService.fetchArticles(skip: skip, limit: limit);
  }

  Future<Article> getArticleById(int id) async {
    return await _articlesApiService.fetchArticleById(id);
  }

  Future<Map<String, dynamic>> getArticlesCount() async {
    return await _articlesApiService.fetchArticlesCount();
  }
}

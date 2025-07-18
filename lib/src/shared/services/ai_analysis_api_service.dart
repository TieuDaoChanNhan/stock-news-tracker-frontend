import 'package:dio/dio.dart';
import 'package:stock_tracker_app/src/shared/models/ai_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class AIAnalysisApiService {
  final Dio _dio;
  
  AIAnalysisApiService(this._dio);

  Future<AIAnalysis?> getAIAnalysisForArticle(int articleId) async {
    try {
      final response = await _dio.get('${AppConstants.aiAnalysisEndpoint}/article/$articleId');
      
      if (response.statusCode == 200) {
        return AIAnalysis.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // Không có AI analysis cho article này
        return null;
      }
      throw Exception('Failed to load AI analysis: $e');
    }
  }

  Future<List<ArticleWithAnalysis>> getHighImpactArticles({
    double minImpact = 0.7,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.aiAnalysisEndpoint}/high-impact',
        queryParameters: {'min_impact': minImpact},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ArticleWithAnalysis.fromJson(json)).toList();
      }
      throw Exception('Failed to load high impact articles');
    } catch (e) {
      throw Exception('Failed to load high impact articles: $e');
    }
  }

  Future<List<ArticleWithAnalysis>> getArticlesByCategory(String category) async {
    try {
      final response = await _dio.get('${AppConstants.aiAnalysisEndpoint}/category/$category');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ArticleWithAnalysis.fromJson(json)).toList();
      }
      throw Exception('Failed to load articles by category');
    } catch (e) {
      throw Exception('Failed to load articles by category: $e');
    }
  }
}

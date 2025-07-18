import 'package:dio/dio.dart';
import 'package:stock_tracker_app/src/shared/models/ai_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/models/article_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class ArticlesApiService {
  final Dio _dio;

  ArticlesApiService(this._dio);

  Future<List<Article>> fetchArticles({
    int skip = AppConstants.defaultSkip,
    int limit = AppConstants.defaultLimit,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.articlesEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Article> fetchArticleById(int id) async {
    try {
      final response = await _dio.get('${AppConstants.articlesEndpoint}/$id');
      
      if (response.statusCode == 200) {
        return Article.fromJson(response.data);
      } else {
        throw Exception('Failed to load article: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchArticlesCount() async {
    try {
      final response = await _dio.get(AppConstants.articlesCountEndpoint);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load articles count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Article>> fetchArticlesByCategory(String category) async {
    try {
      final response = await _dio.get(
        '${AppConstants.aiAnalysisEndpoint}/category/$category'
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles by category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Article>> fetchHighImpactArticles({double minImpact = 0.7}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.aiAnalysisEndpoint}/high-impact',
        queryParameters: {'min_impact': minImpact},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load high impact articles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<AIAnalysis> fetchAIAnalysis(int articleId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.aiAnalysisEndpoint}/article/$articleId'
      );
      
      if (response.statusCode == 200) {
        return AIAnalysis.fromJson(response.data);
      } else {
        throw Exception('Failed to load AI analysis: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

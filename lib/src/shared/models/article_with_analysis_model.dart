import 'article_model.dart';
import 'ai_analysis_model.dart';

class ArticleWithAnalysis {
  final Article article;
  final AIAnalysis? aiAnalysis;

  ArticleWithAnalysis({
    required this.article,
    this.aiAnalysis,
  });

  factory ArticleWithAnalysis.fromJson(Map<String, dynamic> json) {
    return ArticleWithAnalysis(
      article: Article.fromJson(json),
      aiAnalysis: json['ai_analysis'] != null 
          ? AIAnalysis.fromJson(json['ai_analysis']) 
          : null,
    );
  }

  // Convenience getters
  String? get category => aiAnalysis?.category;
  double? get sentimentScore => aiAnalysis?.sentimentScore;
  double? get impactScore => aiAnalysis?.impactScore;
  String get sentimentText => aiAnalysis?.sentimentText ?? 'N/A';
  String get impactText => aiAnalysis?.impactText ?? 'N/A';
}

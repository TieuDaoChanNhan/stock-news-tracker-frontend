import 'dart:convert';

class AIAnalysis {
  final int id;
  final int articleId;
  final String? summary;
  final String? category;
  final double? sentimentScore;
  final double? impactScore;
  final List<String>? keywordsExtracted;
  final Map<String, dynamic>? analysisMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIAnalysis({
    required this.id,
    required this.articleId,
    this.summary,
    this.category,
    this.sentimentScore,
    this.impactScore,
    this.keywordsExtracted,
    this.analysisMetadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    // ✅ SỬA: Handle keywords_extracted
    List<String>? keywords;
    if (json['keywords_extracted'] != null) {
      if (json['keywords_extracted'] is List) {
        keywords = List<String>.from(json['keywords_extracted']);
      }
    }

    // ✅ SỬA: Handle analysis_metadata - có thể là string JSON hoặc object
    Map<String, dynamic>? analysisMetadata;
    if (json['analysis_metadata'] != null) {
      if (json['analysis_metadata'] is String) {
        // Nếu là string JSON, parse nó
        try {
          analysisMetadata = jsonDecode(json['analysis_metadata']) as Map<String, dynamic>;
        } catch (e) {
          print('Error parsing analysis_metadata: $e');
          analysisMetadata = null;
        }
      } else if (json['analysis_metadata'] is Map<String, dynamic>) {
        // Nếu đã là object, sử dụng trực tiếp
        analysisMetadata = json['analysis_metadata'] as Map<String, dynamic>;
      }
    }

    return AIAnalysis(
      id: json['id'],
      articleId: json['article_id'],
      summary: json['summary'],
      category: json['category'],
      sentimentScore: json['sentiment_score']?.toDouble(),
      impactScore: json['impact_score']?.toDouble(),
      keywordsExtracted: keywords,
      analysisMetadata: analysisMetadata,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'summary': summary,
      'category': category,
      'sentiment_score': sentimentScore,
      'impact_score': impactScore,
      'keywords_extracted': keywordsExtracted,
      'analysis_metadata': analysisMetadata != null 
          ? jsonEncode(analysisMetadata) 
          : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get sentimentText {
    if (sentimentScore == null) return 'N/A';
    if (sentimentScore! > 0.1) return 'Tích cực';
    if (sentimentScore! < -0.1) return 'Tiêu cực';
    return 'Trung tính';
  }

  String get impactText {
    if (impactScore == null) return 'N/A';
    if (impactScore! >= 0.7) return 'Cao';
    if (impactScore! >= 0.4) return 'Trung bình';
    return 'Thấp';
  }

  // ✅ THÊM: Getters để access analysis_metadata dễ dàng
  String? get sentimentFromMetadata {
    return analysisMetadata?['sentiment'] as String?;
  }

  String? get impactLevelFromMetadata {
    return analysisMetadata?['impact_level'] as String?;
  }

  List<String>? get keyEntitiesFromMetadata {
    final entities = analysisMetadata?['key_entities'];
    if (entities is List) {
      return List<String>.from(entities);
    }
    return null;
  }

  String? get analysisSummaryFromMetadata {
    return analysisMetadata?['analysis_summary'] as String?;
  }
}

import 'package:intl/intl.dart';

class Article {
  final int id;
  final String title;
  final String url;
  final String? summary;
  final String? publishedDateStr;
  final String sourceUrl;
  final String? contentHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.url,
    this.summary,
    this.publishedDateStr,
    required this.sourceUrl,
    this.contentHash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      summary: json['summary'],
      publishedDateStr: json['published_date_str'],
      sourceUrl: json['source_url'],
      contentHash: json['content_hash'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'summary': summary,
      'published_date_str': publishedDateStr,
      'source_url': sourceUrl,
      'content_hash': contentHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ THÊM: Helper getter cho time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // ✅ THÊM: Helper getter cho formatted date
  String get formattedDate {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt);
  }
}
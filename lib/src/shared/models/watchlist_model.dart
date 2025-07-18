class WatchlistItem {
  final int id;
  final String userId;
  final String itemType; // 'STOCK_SYMBOL' hoặc 'KEYWORD'
  final String itemValue;
  final DateTime createdAt;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemValue,
    required this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'],
      userId: json['user_id'],
      itemType: json['item_type'],
      itemValue: json['item_value'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType,
      'item_value': itemValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'item_type': itemType,
      'item_value': itemValue,
    };
  }

  bool get isKeyword => itemType == 'KEYWORD';
  bool get isStockSymbol => itemType == 'STOCK_SYMBOL';

  String get displayText {
    if (isKeyword) {
      return '🔍 $itemValue';
    } else {
      return '📈 $itemValue';
    }
  }
}

class CrawlSource {
  final int id;
  final String name;
  final String url;
  final String articleContainerSelector;
  final String titleSelector;
  final String linkSelector;
  final String? summarySelector;
  final String? dateSelector;
  final bool isActive;
  final DateTime? lastCrawledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CrawlSource({
    required this.id,
    required this.name,
    required this.url,
    required this.articleContainerSelector,
    required this.titleSelector,
    required this.linkSelector,
    this.summarySelector,
    this.dateSelector,
    required this.isActive,
    this.lastCrawledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CrawlSource.fromJson(Map<String, dynamic> json) {
    return CrawlSource(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      articleContainerSelector: json['article_container_selector'],
      titleSelector: json['title_selector'],
      linkSelector: json['link_selector'],
      summarySelector: json['summary_selector'],
      dateSelector: json['date_selector'],
      isActive: json['is_active'],
      lastCrawledAt: json['last_crawled_at'] != null
          ? DateTime.parse(json['last_crawled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get statusText => isActive ? 'Hoạt động' : 'Tạm dừng';
  String get lastCrawledText {
    if (lastCrawledAt == null) return 'Chưa crawl';
    final now = DateTime.now();
    final difference = now.difference(lastCrawledAt!);
    
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
}

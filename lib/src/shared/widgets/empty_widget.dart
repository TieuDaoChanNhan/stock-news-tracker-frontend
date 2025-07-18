import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customIcon;
  final Color? iconColor;
  final IconData? iconForButton;
  
  const EmptyWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
    this.customIcon,
    this.iconColor, this.iconForButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIcon != null)
              customIcon!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: iconColor ?? Theme.of(context).colorScheme.outline,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon:  Icon(iconForButton ?? Icons.add),
                label: Text(actionText ?? 'Thêm mới'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyNewsWidget extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const EmptyNewsWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Chưa có tin tức',
      subtitle: 'Không có tin tức nào được tìm thấy.\nHệ thống sẽ tự động cập nhật tin tức mới.',
      icon: Icons.article_outlined,
      onAction: onRefresh,
      actionText: 'Làm mới',
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;
  
  const EmptySearchWidget({
    super.key, 
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Không tìm thấy kết quả',
      subtitle: searchQuery != null 
          ? 'Không có kết quả nào cho "$searchQuery".\nThử tìm kiếm với từ khóa khác.'
          : 'Thử tìm kiếm với từ khóa khác.',
      icon: Icons.search_off,
      onAction: onClearSearch,
      actionText: 'Xóa tìm kiếm',
    );
  }
}

class EmptyCompaniesWidget extends StatelessWidget {
  final VoidCallback? onAddCompany;
  
  const EmptyCompaniesWidget({super.key, this.onAddCompany});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Chưa có công ty nào',
      subtitle: 'Thêm công ty để bắt đầu theo dõi chỉ số tài chính và tin tức.',
      icon: Icons.business_outlined,
      onAction: onAddCompany,
      actionText: 'Thêm công ty',
    );
  }
}

class EmptyWatchlistWidget extends StatelessWidget {
  final VoidCallback? onAddItem;
  
  const EmptyWatchlistWidget({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Watchlist trống',
      subtitle: 'Thêm từ khóa hoặc mã cổ phiếu để nhận thông báo tin tức liên quan.',
      icon: Icons.bookmark_outline,
      onAction: onAddItem,
      actionText: 'Thêm item',
    );
  }
}

class EmptyAnalyticsWidget extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const EmptyAnalyticsWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Chưa có dữ liệu phân tích',
      subtitle: 'Cần có dữ liệu tin tức để thực hiện phân tích.\nVui lòng quay lại sau.',
      icon: Icons.analytics_outlined,
      onAction: onRefresh,
      actionText: 'Kiểm tra lại',
    );
  }
}

class EmptyMetricsWidget extends StatelessWidget {
  final VoidCallback? onFetchMetrics;
  
  const EmptyMetricsWidget({super.key, this.onFetchMetrics});

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      title: 'Chưa có dữ liệu tài chính',
      subtitle: 'Chưa có dữ liệu tài chính cho công ty này.\nHãy fetch metrics mới.',
      icon: Icons.trending_up,
      onAction: onFetchMetrics,
      actionText: 'Fetch metrics',
    );
  }
}

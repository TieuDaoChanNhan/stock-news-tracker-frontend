import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';

class AnalyticsPreviewSection extends StatelessWidget {
  final Map<String, int> articlesByCategory;
  final String sentimentTrend;
  final int highImpactCount;

  const AnalyticsPreviewSection({
    super.key,
    required this.articlesByCategory,
    required this.sentimentTrend,
    required this.highImpactCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Phân tích xu hướng',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.analytics),
              child: const Text('Xem chi tiết'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                context,
                'Xu hướng cảm xúc',
                sentimentTrend,
                _getSentimentIcon(sentimentTrend),
                _getSentimentColor(sentimentTrend),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnalyticsCard(
                context,
                'Tin tác động cao',
                '$highImpactCount tin',
                Icons.priority_high,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Category distribution
        if (articlesByCategory.isNotEmpty) ...[
          Text(
            'Phân bố theo danh mục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: articlesByCategory.entries.take(4).length,
              itemBuilder: (context, index) {
                final entry = articlesByCategory.entries.elementAt(index);
                return _buildCategoryChip(context, entry.key, entry.value);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category, int count) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'Tích cực':
        return Icons.sentiment_very_satisfied;
      case 'Tiêu cực':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Tích cực':
        return Colors.green;
      case 'Tiêu cực':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

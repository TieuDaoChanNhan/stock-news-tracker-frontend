import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';

class RecentArticlesSection extends StatelessWidget {
  final List<ArticleWithAnalysis> articles; // ✅ SỬA: ArticleWithAnalysis

  const RecentArticlesSection({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chưa có tin tức',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hệ thống sẽ tự động cập nhật tin tức mới',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.take(5).length,
          itemBuilder: (context, index) {
            final articleWithAnalysis = articles[index];
            return _buildArticleCard(context, articleWithAnalysis);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.toNamed(AppRoutes.articles),
                child: const Text('Xem tất cả tin tức'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleWithAnalysis articleWithAnalysis) {
    final article = articleWithAnalysis.article;
    final aiAnalysis = articleWithAnalysis.aiAnalysis;
    
    final categoryColor = aiAnalysis?.category != null 
        ? AppConstants.categoryColors[aiAnalysis!.category!] ?? AppConstants.categoryColors['Không liên quan']!
        : AppConstants.categoryColors['Không liên quan']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          article.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.summary != null) ...[
              const SizedBox(height: 8),
              Text(
                article.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  article.timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (aiAnalysis?.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(categoryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      aiAnalysis!.category!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(categoryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (aiAnalysis != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (aiAnalysis.sentimentScore != null)
                    _buildSentimentChip(context, aiAnalysis.sentimentScore!),
                  const SizedBox(width: 8),
                  if (aiAnalysis.impactScore != null)
                    _buildImpactChip(context, aiAnalysis.impactScore!),
                ],
              ),
            ],
          ],
        ),
        onTap: () => Get.toNamed(
          AppRoutes.articleDetail.replaceAll(':id', article.id.toString()),
        ),
      ),
    );
  }

  Widget _buildSentimentChip(BuildContext context, double sentiment) {
    Color color;
    String text;
    IconData icon;
    
    if (sentiment > 0.1) {
      color = Colors.green;
      text = 'Tích cực';
      icon = Icons.trending_up;
    } else if (sentiment < -0.1) {
      color = Colors.red;
      text = 'Tiêu cực';
      icon = Icons.trending_down;
    } else {
      color = Colors.grey;
      text = 'Trung tính';
      icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactChip(BuildContext context, double impact) {
    Color color;
    String text;
    
    if (impact >= 0.7) {
      color = Colors.red;
      text = 'Tác động cao';
    } else if (impact >= 0.4) {
      color = Colors.orange;
      text = 'Tác động TB';
    } else {
      color = Colors.green;
      text = 'Tác động thấp';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

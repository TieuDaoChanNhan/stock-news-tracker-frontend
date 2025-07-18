import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/articles/controllers/article_detail_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleDetailController>();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết tin tức'),
          actions: [
            Obx(() {
              // ✅ SỬA: Access từ articleWithAnalysis
              final article = controller.article;
              if (article?.url != null) {
                return IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _launchUrl(article!.url),
                );
              }
              return const SizedBox.shrink();
            }),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final article = controller.article;
                if (article != null) {
                  Get.snackbar(
                    'Chia sẻ',
                    'Tính năng chia sẻ sẽ sớm có',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Đang tải bài viết...');
          }
      
          if (controller.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: controller.errorMessage,
              onRetry: () {
                final articleId = Get.parameters['id'];
                if (articleId != null) {
                  controller.loadArticle(int.parse(articleId));
                }
              },
            );
          }
      
          // ✅ SỬA: Lấy articleWithAnalysis thay vì article
          final articleWithAnalysis = controller.articleWithAnalysis;
          if (articleWithAnalysis == null) {
            return const Center(child: Text('Không tìm thấy bài viết'));
          }

          final article = articleWithAnalysis.article;
          final aiAnalysis = articleWithAnalysis.aiAnalysis;
      
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section with title
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      // ✅ SỬA: Access từ aiAnalysis
                      if (aiAnalysis?.category != null)
                        _buildCategoryChip(context, aiAnalysis!.category!),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
      
                      // Meta info
                      _buildMetaInfo(context, article),
                    ],
                  ),
                ),
      
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Analysis Section
                      // ✅ SỬA: Kiểm tra aiAnalysis riêng biệt
                      if (aiAnalysis != null) ...[
                        _buildAIAnalysisSection(context, aiAnalysis),
                        const SizedBox(height: 32),
                      ],
      
                      // Summary
                      if (article.summary != null) ...[
                        _buildSectionHeader(context, 'Tóm tắt', Icons.summarize),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            article.summary!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
      
                      // Source section
                      _buildSourceSection(context, article),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final categoryColor = AppConstants.categoryColors[category] ?? 
                         AppConstants.categoryColors['Không liên quan']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(categoryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(categoryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(categoryColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Color(categoryColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context, article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                // ✅ SỬA: Sử dụng timeAgo thay vì formattedDate
                'Thời gian: ${article.timeAgo}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.source,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nguồn: ${article.sourceUrl}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysisSection(BuildContext context, aiAnalysis) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Phân tích AI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Sentiment and Impact
            Row(
              children: [
                if (aiAnalysis.sentimentScore != null) ...[
                  Expanded(
                    child: _buildAnalysisMetric(
                      context,
                      'Cảm xúc',
                      aiAnalysis.sentimentText,
                      _getSentimentIcon(aiAnalysis.sentimentScore!),
                      _getSentimentColor(aiAnalysis.sentimentScore!),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (aiAnalysis.impactScore != null)
                  Expanded(
                    child: _buildAnalysisMetric(
                      context,
                      'Tác động',
                      aiAnalysis.impactText,
                      Icons.trending_up,
                      _getImpactColor(aiAnalysis.impactScore!),
                    ),
                  ),
              ],
            ),
            
            if (aiAnalysis.summary != null) ...[
              const SizedBox(height: 20),
              Text(
                'Tóm tắt AI',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  aiAnalysis.summary!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            if (aiAnalysis.keywordsExtracted != null && 
                aiAnalysis.keywordsExtracted!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Từ khóa chính',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: aiAnalysis.keywordsExtracted!.map<Widget>((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      keyword,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(BuildContext context, article) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Nguồn bài viết', Icons.link),
            const SizedBox(height: 16),
            Text(
              'Đọc bài viết gốc tại:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.sourceUrl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(article.url),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Đọc bài viết đầy đủ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSentimentIcon(double sentiment) {
    if (sentiment > 0.1) return Icons.sentiment_very_satisfied;
    if (sentiment < -0.1) return Icons.sentiment_very_dissatisfied;
    return Icons.sentiment_neutral;
  }

  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0.1) return Colors.green;
    if (sentiment < -0.1) return Colors.red;
    return Colors.grey;
  }

  Color _getImpactColor(double impact) {
    if (impact >= 0.7) return Colors.red;
    if (impact >= 0.4) return Colors.orange;
    return Colors.green;
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mở liên kết',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/articles/controllers/articles_controller.dart';
import 'package:stock_tracker_app/src/shared/models/article_with_analysis_model.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/empty_widget.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articlesController = Get.find<ArticlesController>();
    final searchController = TextEditingController();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tin tức'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => articlesController.refreshArticles(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tin tức...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          articlesController.clearFilters();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) {
                      // Implement search logic nếu backend có search API
                      articlesController.filterBySearch(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Filter Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => Row(
                      children: [
                        // High Impact Filter
                        FilterChip(
                          selected: articlesController.showHighImpactOnly,
                          label: const Text('Tác động cao'),
                          onSelected: (selected) {
                            articlesController.toggleHighImpactFilter();
                          },
                          avatar: const Icon(Icons.priority_high, size: 16),
                        ),
                        const SizedBox(width: 8),
                        
                        // Category Filters
                        // ...articlesController.availableCategories.map((category) {
                        //   final isSelected = articlesController.selectedCategory == category;
                        //   final categoryColor = AppConstants.categoryColors[category] ?? 
                        //                        AppConstants.categoryColors['Không liên quan']!;
                          
                        //   return Padding(
                        //     padding: const EdgeInsets.only(right: 8),
                        //     child: FilterChip(
                        //       selected: isSelected,
                        //       label: Text(category),
                        //       onSelected: (selected) {
                        //         articlesController.filterByCategory(
                        //           selected ? category : null
                        //         );
                        //       },
                        //       backgroundColor: Color(categoryColor).withOpacity(0.1),
                        //       selectedColor: Color(categoryColor).withOpacity(0.2),
                        //     ),
                        //   );
                        // }).toList(),
                        
                        // Clear Filter
                        if (articlesController.selectedCategory != null || 
                            articlesController.showHighImpactOnly)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionChip(
                              label: const Text('Xóa bộ lọc'),
                              onPressed: () => articlesController.clearFilters(),
                              avatar: const Icon(Icons.clear, size: 16),
                            ),
                          ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            
            // Articles List
            Expanded(
              child: Obx(() {
                if (articlesController.isLoading && articlesController.articles.isEmpty) {
                  return const LoadingWidget(message: 'Đang tải tin tức...');
                }
      
                if (articlesController.errorMessage.isNotEmpty && 
                    articlesController.articles.isEmpty) {
                  return ErrorDisplayWidget(
                    message: articlesController.errorMessage,
                    onRetry: () => articlesController.refreshArticles(),
                  );
                }
      
                if (articlesController.articles.isEmpty) {
                  return EmptyWidget(
                    title: 'Không tìm thấy tin tức',
                    subtitle: 'Thử điều chỉnh bộ lọc hoặc quay lại sau',
                    icon: Icons.error,
                    onAction: () => articlesController.clearFilters(),
                    actionText: 'Xóa bộ lọc',
                    iconForButton: Icons.search_off,
                  );
                }
      
                return RefreshIndicator(
                  onRefresh: () => articlesController.refreshArticles(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: articlesController.articles.length + 
                        (articlesController.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Load more indicator
                      if (index == articlesController.articles.length) {
                        if (articlesController.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () => articlesController.loadMoreArticles(),
                              child: const Text('Tải thêm'),
                            ),
                          );
                        }
                      }
      
                      final article = articlesController.articles[index];
                      return _buildArticleItem(context, article);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, ArticleWithAnalysis articleWithAnalysis) {
  final article = articleWithAnalysis.article;
  final aiAnalysis = articleWithAnalysis.aiAnalysis;
  
  // Có thể null-safe access AI analysis
  final categoryColor = aiAnalysis?.category != null 
      ? AppConstants.categoryColors[aiAnalysis!.category!] ?? AppConstants.categoryColors['Không liên quan']!
      : AppConstants.categoryColors['Không liên quan']!;
  
  return Card(
    child: ListTile(
      title: Text(article.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.summary != null) ...[
            Text(article.summary!),
            const SizedBox(height: 8),
          ],
          
          // AI Analysis indicators (có thể null)
          if (aiAnalysis != null) ...[
            Row(
              children: [
                if (aiAnalysis.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(categoryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      aiAnalysis.category!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(categoryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (aiAnalysis.sentimentScore != null)
                  _buildSentimentChip(context, aiAnalysis.sentimentScore!),
              ],
            ),
          ] else ...[
            // Hiển thị khi chưa có AI analysis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đang phân tích...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
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
      text = 'Cao';
    } else if (impact >= 0.4) {
      color = Colors.orange;
      text = 'TB';
    } else {
      color = Colors.green;
      text = 'Thấp';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Tác động: $text',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

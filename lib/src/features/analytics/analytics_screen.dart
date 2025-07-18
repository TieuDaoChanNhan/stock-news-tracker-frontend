import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_tracker_app/src/features/analytics/controllers/analytics_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsController = Get.put(AnalyticsController());

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phân tích & Thống kê'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => analyticsController.refreshAnalytics(),
            ),
          ],
        ),
        body: Obx(() {
          if (analyticsController.isLoading) {
            return const LoadingWidget(message: 'Đang phân tích dữ liệu...');
          }

          if (analyticsController.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: analyticsController.errorMessage,
              onRetry: () => analyticsController.refreshAnalytics(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => analyticsController.refreshAnalytics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Selector
                    _buildTimeRangeSelector(context, analyticsController),
                    const SizedBox(height: 24),

                    // Summary Cards
                    _buildSummaryCards(context, analyticsController),
                    const SizedBox(height: 24),

                    // Category Distribution Chart
                    _buildCategoryChart(context, analyticsController),
                    const SizedBox(height: 24),

                    // Sentiment Analysis Chart
                    _buildSentimentChart(context, analyticsController),
                    const SizedBox(height: 24),

                    // Impact Analysis Chart
                    _buildImpactChart(context, analyticsController),
                    const SizedBox(height: 24),

                    // High Impact Articles
                    _buildHighImpactSection(context, analyticsController),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeRangeSelector(
    BuildContext context,
    AnalyticsController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khoảng thời gian',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTimeRangeChip(context, 'Tuần', 'week', controller),
                const SizedBox(width: 8),
                _buildTimeRangeChip(context, 'Tháng', 'month', controller),
                const SizedBox(width: 8),
                _buildTimeRangeChip(context, 'Quý', 'quarter', controller),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeChip(
    BuildContext context,
    String label,
    String value,
    AnalyticsController controller,
  ) {
    final isSelected = controller.selectedTimeRange == value;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          controller.changeTimeRange(value);
        }
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AnalyticsController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              context,
              'Tổng bài viết',
              '${controller.totalArticlesAnalyzed}',
              Icons.article_outlined,
              Colors.blue,
            ),
            _buildSummaryCard(
              context,
              'Cảm xúc TB',
              '${(controller.averageSentiment * 100).toStringAsFixed(1)}%',
              Icons.sentiment_satisfied,
              _getSentimentColor(controller.averageSentiment),
            ),
            _buildSummaryCard(
              context,
              'Tác động TB',
              '${(controller.averageImpact * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange,
            ),
            _buildSummaryCard(
              context,
              'Danh mục chính',
              controller.dominantCategory,
              Icons.category,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    AnalyticsController controller,
  ) {
    if (controller.categoryDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân bổ theo danh mục',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(
                    controller.categoryDistribution,
                  ),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(controller.categoryDistribution),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, int> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.key} (${entry.value})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildSentimentChart(
    BuildContext context,
    AnalyticsController controller,
  ) {
    if (controller.sentimentTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân tích cảm xúc',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250, // ✅ SỬA: Tăng height cho chart
              child: BarChart(
                BarChartData(
                  barGroups: _buildSentimentBarGroups(
                    controller.sentimentTrends,
                  ),
                  // ✅ SỬA: Improved spacing và formatting
                  titlesData: FlTitlesData(
                    // Left titles (Y-axis) với more space
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60, // ✅ SỬA: Tăng từ default ~40 lên 60
                        interval: 0.2, // ✅ SỬA: Show labels mỗi 0.2 units
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                            ), // ✅ SỬA: Thêm padding
                            child: Text(
                              value.toStringAsFixed(
                                1,
                              ), // ✅ SỬA: Format with 1 decimal
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Bottom titles (X-axis) với better formatting
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // ✅ SỬA: Space cho bottom labels
                        getTitlesWidget: (value, meta) {
                          final labels = controller.sentimentLabels;
                          if (value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                              ), // ✅ SỬA: Thêm padding
                              child: Text(
                                labels[value.toInt()],
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  // ✅ SỬA: Improved border và grid
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  // ✅ SỬA: Show grid để dễ đọc
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 0.2,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  // ✅ SỬA: Set min/max để có better spacing
                  minY: 0,
                  maxY: _calculateMaxY(controller.sentimentTrends),
                  // ✅ SỬA: Thêm margin cho bars
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final labels = controller.sentimentLabels;
                        final value = rod.toY;
                        return BarTooltipItem(
                          '${labels[groupIndex]}\n${value.toStringAsFixed(2)}',
                          TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ THÊM: Helper method để calculate max Y value
  double _calculateMaxY(Map<String, double> data) {
    if (data.isEmpty) return 1.0;

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    // Thêm 20% padding ở top và round up
    return ((maxValue * 1.2) * 10).ceil() / 10.0;
  }

  List<BarChartGroupData> _buildSentimentBarGroups(Map<String, double> data) {
    final colors = [Colors.green, Colors.grey, Colors.red];

    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: colors[index % colors.length],
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildImpactChart(
    BuildContext context,
    AnalyticsController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân tích tác động',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...controller.impactAnalysis.entries.map((entry) {
              final total = controller.impactAnalysis.values.reduce(
                (a, b) => a + b,
              );
              final percentage = total > 0 ? (entry.value / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tác động ${entry.key}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${entry.value} (${(percentage * 100).toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getImpactColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHighImpactSection(
    BuildContext context,
    AnalyticsController controller,
  ) {
    if (controller.highImpactArticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tin tức tác động cao',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.articles),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.highImpactArticles.take(5).length,
          itemBuilder: (context, index) {
            final article = controller.highImpactArticles[index];
            return _buildHighImpactArticleCard(context, article);
          },
        ),
      ],
    );
  }

  Widget _buildHighImpactArticleCard(BuildContext context, article) {
    final categoryColor =
        AppConstants.categoryColors[article.aiAnalysis?.category] ??
        AppConstants.categoryColors['Không liên quan']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(categoryColor),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          article.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (article.aiAnalysis?.category != null)
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
                      article.aiAnalysis!.category!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(categoryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (article.aiAnalysis?.impactScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tác động cao',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              article.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap:
            () => Get.toNamed(
              AppRoutes.articleDetail.replaceAll(':id', article.id.toString()),
            ),
      ),
    );
  }

  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0.1) return Colors.green;
    if (sentiment < -0.1) return Colors.red;
    return Colors.grey;
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'Cao':
        return Colors.red;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

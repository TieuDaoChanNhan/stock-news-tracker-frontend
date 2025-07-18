import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stock_tracker_app/src/features/dashboard/widgets/quick_stats_section.dart';
import 'package:stock_tracker_app/src/features/dashboard/widgets/recent_articles_section.dart';
import 'package:stock_tracker_app/src/features/dashboard/widgets/company_overview_section.dart';
import 'package:stock_tracker_app/src/features/dashboard/widgets/analytics_preview_section.dart';
import 'package:stock_tracker_app/src/shared/widgets/dashboard_header.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/utils/app_routes.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => dashboardController.refreshDashboard(),
            ),
          ],
        ),
        body: Obx(() {
          if (dashboardController.isLoading) {
            return const LoadingWidget(message: 'Đang tải dashboard...');
          }
      
          if (dashboardController.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: dashboardController.errorMessage,
              onRetry: () => dashboardController.refreshDashboard(),
            );
          }
      
          return RefreshIndicator(
            onRefresh: () => dashboardController.refreshDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với thống kê tổng quan
                    const DashboardHeader(),
                    const SizedBox(height: 24),
      
                    // Quick Stats từ API thực tế
                    QuickStatsSection(
                      articlesCount: dashboardController.articlesCount,
                      companiesData: dashboardController.dashboardData,
                      watchlistCount: dashboardController.watchlistItems.length,
                    ),
                    const SizedBox(height: 24),
      
                    // Company Overview từ dashboard API
                    CompanyOverviewSection(
                      dashboardData: dashboardController.dashboardData,
                    ),
                    const SizedBox(height: 24),
      
                    // Recent Articles với AI Analysis
                    Text(
                      'Tin tức gần đây',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentArticlesSection(
                      articles: dashboardController.recentArticles,
                    ),
                    const SizedBox(height: 24),
      
                    // Analytics Preview
                    AnalyticsPreviewSection(
                      articlesByCategory: dashboardController.articlesByCategory,
                      sentimentTrend: dashboardController.sentimentTrend,
                      highImpactCount: dashboardController.highImpactArticles.length,
                    ),
                    const SizedBox(height: 24),
      
                    // Quick Actions
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Truy cập nhanh',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionCard(
              context,
              'Tất cả tin tức',
              Icons.article_outlined,
              () => Get.toNamed(AppRoutes.articles),
            ),
            _buildQuickActionCard(
              context,
              'Công ty',
              Icons.business_outlined,
              () => Get.toNamed(AppRoutes.companies),
            ),
            _buildQuickActionCard(
              context,
              'Watchlist',
              Icons.bookmark_outline,
              () => Get.toNamed(AppRoutes.watchlist),
            ),
            _buildQuickActionCard(
              context,
              'Phân tích',
              Icons.analytics_outlined,
              () => Get.toNamed(AppRoutes.analytics),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

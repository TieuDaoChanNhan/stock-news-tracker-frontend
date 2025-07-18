import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/settings/controllers/settings_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cài đặt'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => settingsController.refreshSettings(),
            ),
          ],
        ),
        body: Obx(() {
          if (settingsController.isLoading) {
            return const LoadingWidget(message: 'Đang tải cài đặt...');
          }
      
          if (settingsController.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: settingsController.errorMessage,
              onRetry: () => settingsController.refreshSettings(),
            );
          }
      
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // System Health Card
              _buildSystemHealthCard(context, settingsController),
              const SizedBox(height: 16),
      
              // System Statistics
              _buildSystemStatsCard(context, settingsController),
              const SizedBox(height: 16),
      
              // App Preferences
              _buildAppPreferencesCard(context, settingsController),
              const SizedBox(height: 16),
      
              // Crawl Sources Management
              _buildCrawlSourcesCard(context, settingsController),
              const SizedBox(height: 16),
      
              // System Actions
              _buildSystemActionsCard(context, settingsController),
              const SizedBox(height: 16),
      
              // App Info
              _buildAppInfoCard(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSystemHealthCard(BuildContext context, SettingsController controller) {
    final healthStatus = controller.systemHealthStatus;
    final healthColor = _getHealthColor(healthStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: healthColor),
                const SizedBox(width: 12),
                Text(
                  'Tình trạng hệ thống',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    healthStatus,
                    style: TextStyle(
                      color: healthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // API Usage Indicator
            Row(
              children: [
                Text(
                  'API Usage: ${controller.systemStats['api_usage_today']}/${controller.systemStats['api_limit']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${controller.apiUsagePercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.apiUsagePercentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getApiUsageColor(controller.apiUsagePercentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatsCard(BuildContext context, SettingsController controller) {
    final stats = controller.systemStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê hệ thống',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              childAspectRatio: 2,
              children: [
                _buildStatItem(
                  context, 
                  'Tổng tin tức', 
                  '${stats['total_articles']}',
                  Icons.article_outlined,
                ),
                _buildStatItem(
                  context, 
                  'Công ty', 
                  '${stats['total_companies']}',
                  Icons.business_outlined,
                ),
                _buildStatItem(
                  context, 
                  'Có dữ liệu', 
                  '${stats['companies_with_data']}',
                  Icons.check_circle_outline,
                ),
                _buildStatItem(
                  context, 
                  'Watchlist', 
                  '${stats['watchlist_items']}',
                  Icons.bookmark_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesCard(BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tùy chọn ứng dụng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Chế độ tối'),
              subtitle: const Text('Sử dụng theme màu tối'),
              value: controller.isDarkMode,
              onChanged: (value) => controller.toggleDarkMode(value),
              secondary: const Icon(Icons.dark_mode),
            ),
            
            SwitchListTile(
              title: const Text('Thông báo'),
              subtitle: const Text('Nhận thông báo khi có tin tức mới'),
              value: controller.enableNotifications,
              onChanged: (value) => controller.toggleNotifications(value),
              secondary: const Icon(Icons.notifications),
            ),
            
            SwitchListTile(
              title: const Text('Tự động cập nhật'),
              subtitle: const Text('Tự động làm mới dữ liệu'),
              value: controller.autoRefresh,
              onChanged: (value) => controller.toggleAutoRefresh(value),
              secondary: const Icon(Icons.refresh),
            ),
            
            ListTile(
              title: const Text('Khoảng cách cập nhật'),
              subtitle: Text('${controller.refreshInterval} phút'),
              leading: const Icon(Icons.timer),
              trailing: DropdownButton<int>(
                value: controller.refreshInterval,
                items: [5, 10, 15, 30, 60].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes phút'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.setRefreshInterval(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrawlSourcesCard(BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý nguồn crawl',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.activeSources.length} hoạt động • ${controller.inactiveSources.length} tạm dừng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            if (controller.crawlSources.isEmpty)
              const Text('Chưa có nguồn crawl nào')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.crawlSources.take(5).length, // Chỉ hiển thị 5 nguồn đầu
                itemBuilder: (context, index) {
                  final source = controller.crawlSources[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      source.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Crawl cuối: ${source.lastCrawledText}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: source.isActive,
                      onChanged: (value) => controller.toggleCrawlSource(
                        source.id, 
                        value,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemActionsCard(BuildContext context, SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thao tác hệ thống',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              title: const Text('Xóa cache'),
              subtitle: const Text('Xóa dữ liệu cache tạm thời'),
              leading: const Icon(Icons.clear_all),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => controller.clearCache(),
            ),
            
            ListTile(
              title: const Text('Xuất dữ liệu'),
              subtitle: const Text('Xuất dữ liệu ra file'),
              leading: const Icon(Icons.download),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => controller.exportData(),
            ),
            
            ListTile(
              title: const Text('Làm mới toàn bộ'),
              subtitle: const Text('Tải lại tất cả dữ liệu'),
              leading: const Icon(Icons.refresh),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => controller.refreshSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin ứng dụng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              title: const Text('Phiên bản'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),
            
            ListTile(
              title: const Text('Nhà phát triển'),
              subtitle: const Text('Nguyễn Văn Khuê'),
              leading: const Icon(Icons.person_outline),
            ),
            
            ListTile(
              title: const Text('Backend API'),
              subtitle: const Text('FastAPI + SQLite + AI'),
              leading: const Icon(Icons.api),
            ),
            
            ListTile(
              title: const Text('Liên hệ'),
              subtitle: const Text('khuengv332007@gmail.com'),
              leading: const Icon(Icons.email_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'Tốt':
        return Colors.green;
      case 'Cảnh báo':
        return Colors.orange;
      case 'Lỗi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getApiUsageColor(double percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 70) return Colors.orange;
    return Colors.green;
  }
}

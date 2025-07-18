import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/features/watchlist/controllers/watchlist_controller.dart';
import 'package:stock_tracker_app/src/shared/widgets/loading_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/error_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/empty_widget.dart';
import 'package:stock_tracker_app/src/shared/widgets/main_navigation.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlistController = Get.find<WatchlistController>();

    return MainNavigation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Watchlist & Nguồn'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => watchlistController.showAddItemDialog(),
              tooltip: 'Thêm item mới',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => watchlistController.loadWatchlistData(),
            ),
          ],
        ),
        body: Obx(() {
          if (watchlistController.isLoading) {
            return const LoadingWidget(message: 'Đang tải watchlist...');
          }
      
          if (watchlistController.errorMessage.isNotEmpty) {
            return ErrorDisplayWidget(
              message: watchlistController.errorMessage,
              onRetry: () => watchlistController.loadWatchlistData(),
            );
          }
      
          return RefreshIndicator(
            onRefresh: () => watchlistController.loadWatchlistData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Watchlist Summary
                    _buildWatchlistSummary(context, watchlistController),
                    const SizedBox(height: 24),
      
                    // Watchlist Items
                    _buildWatchlistSection(context, watchlistController),
                    const SizedBox(height: 24),
      
                    // Crawl Sources
                    _buildCrawlSourcesSection(context, watchlistController),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWatchlistSummary(BuildContext context, WatchlistController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan Watchlist',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Từ khóa',
                    '${controller.keywordItems.length}',
                    Icons.search,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Mã CK',
                    '${controller.stockSymbolItems.length}',
                    Icons.show_chart,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Nguồn active',
                    '${controller.activeSources.length}',
                    Icons.source,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Nguồn inactive',
                    '${controller.inactiveSources.length}',
                    Icons.pause_circle,
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistSection(BuildContext context, WatchlistController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Watchlist Items (${controller.watchlistItems.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.showAddItemDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (controller.watchlistItems.isEmpty)
          const EmptyWidget(
            title: 'Chưa có item nào',
            subtitle: 'Thêm từ khóa hoặc mã chứng khoán để theo dõi',
            icon: Icons.bookmark_outline,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.watchlistItems.length,
            itemBuilder: (context, index) {
              final item = controller.watchlistItems[index];
              return _buildWatchlistItem(context, item, controller);
            },
          ),
      ],
    );
  }

  Widget _buildWatchlistItem(BuildContext context, item, WatchlistController controller) {
    final isKeyword = item.isKeyword;
    final color = isKeyword ? Colors.blue : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isKeyword ? Icons.search : Icons.show_chart,
            color: color,
          ),
        ),
        title: Text(
          item.itemValue,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isKeyword ? 'Từ khóa' : 'Mã chứng khoán',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(item.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(
                context, 
                item, 
                controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrawlSourcesSection(BuildContext context, WatchlistController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nguồn Crawl (${controller.crawlSources.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (controller.crawlSources.isEmpty)
          const EmptyWidget(
            title: 'Chưa có nguồn crawl',
            subtitle: 'Cần cấu hình nguồn crawl trong hệ thống',
            icon: Icons.source,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.crawlSources.length,
            itemBuilder: (context, index) {
              final source = controller.crawlSources[index];
              return _buildCrawlSourceItem(context, source, controller);
            },
          ),
      ],
    );
  }

  Widget _buildCrawlSourceItem(BuildContext context, source, WatchlistController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: source.isActive 
              ? Colors.green.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            source.isActive ? Icons.play_arrow : Icons.pause,
            color: source.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          source.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Crawl cuối: ${source.lastCrawledText}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: source.isActive,
          onChanged: (value) => controller.updateCrawlSourceStatus(
            source.id, 
            value,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context, 
    item, 
    WatchlistController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.itemValue}" khỏi watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteWatchlistItem(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

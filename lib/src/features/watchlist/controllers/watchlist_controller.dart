import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/watchlist_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/watchlist_repository.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class WatchlistController extends GetxController {
  final WatchlistRepository _repository = Get.find<WatchlistRepository>();

  final _watchlistItems = <WatchlistItem>[].obs;
  final _crawlSources = <CrawlSource>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  List<WatchlistItem> get watchlistItems => _watchlistItems.value;
  List<CrawlSource> get crawlSources => _crawlSources.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadWatchlistData();
  }

  Future<void> loadWatchlistData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Load watchlist và crawl sources song song
      await Future.wait([
        _loadWatchlistItems(),
        _loadCrawlSources(),
      ]);

    } catch (e) {
      _errorMessage.value = 'Failed to load watchlist data: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadWatchlistItems() async {
    try {
      final items = await _repository.getWatchlist();
      _watchlistItems.value = items;
    } catch (e) {
      print('Failed to load watchlist items: $e');
    }
  }

  Future<void> _loadCrawlSources() async {
    try {
      final sources = await _repository.getCrawlSources();
      _crawlSources.value = sources;
    } catch (e) {
      print('Failed to load crawl sources: $e');
    }
  }

  Future<void> addWatchlistItem({
    required String itemType,
    required String itemValue,
  }) async {
    try {
      // Validate input
      if (itemValue.trim().isEmpty) {
        Get.snackbar('Lỗi', 'Vui lòng nhập giá trị');
        return;
      }

      // Check duplicate
      final isDuplicate = _watchlistItems.any((item) =>
          item.itemType == itemType && 
          item.itemValue.toLowerCase() == itemValue.toLowerCase());

      if (isDuplicate) {
        Get.snackbar('Cảnh báo', 'Item này đã có trong watchlist');
        return;
      }

      final newItem = WatchlistItem(
        id: 0, // Will be set by backend
        userId: AppConstants.userId,
        itemType: itemType,
        itemValue: itemValue.trim(),
        createdAt: DateTime.now(),
      );

      final createdItem = await _repository.addWatchlistItem(newItem);
      
      // Add to local list
      _watchlistItems.add(createdItem);
      
      Get.snackbar(
        'Thành công', 
        'Đã thêm "${itemValue}" vào watchlist',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        'Lỗi', 
        'Không thể thêm item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteWatchlistItem(int itemId) async {
    try {
      await _repository.deleteWatchlistItem(itemId);
      
      // Remove from local list
      _watchlistItems.removeWhere((item) => item.id == itemId);
      
      Get.snackbar(
        'Thành công', 
        'Đã xóa item khỏi watchlist',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        'Lỗi', 
        'Không thể xóa item: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateCrawlSourceStatus(int sourceId, bool isActive) async {
    try {
      await _repository.updateCrawlSource(sourceId, {'is_active': isActive});
      
      // Update local state
      final index = _crawlSources.indexWhere((source) => source.id == sourceId);
      if (index != -1) {
        _crawlSources[index] = CrawlSource(
          id: _crawlSources[index].id,
          name: _crawlSources[index].name,
          url: _crawlSources[index].url,
          articleContainerSelector: _crawlSources[index].articleContainerSelector,
          titleSelector: _crawlSources[index].titleSelector,
          linkSelector: _crawlSources[index].linkSelector,
          summarySelector: _crawlSources[index].summarySelector,
          dateSelector: _crawlSources[index].dateSelector,
          isActive: isActive,
          lastCrawledAt: _crawlSources[index].lastCrawledAt,
          createdAt: _crawlSources[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _crawlSources.refresh();
      }

      Get.snackbar(
        'Thành công', 
        'Đã ${isActive ? "kích hoạt" : "tạm dừng"} nguồn crawl',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      Get.snackbar(
        'Lỗi', 
        'Không thể cập nhật trạng thái: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showAddItemDialog() {
    final typeController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'KEYWORD';

    Get.dialog(
      AlertDialog(
        title: const Text('Thêm Watchlist Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Loại',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'KEYWORD', child: Text('Từ khóa')),
                DropdownMenuItem(value: 'STOCK_SYMBOL', child: Text('Mã cổ phiếu')),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Giá trị',
                hintText: 'VD: AAPL hoặc "lãi suất"',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              addWatchlistItem(
                itemType: selectedType,
                itemValue: valueController.text,
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Analytics getters
  List<WatchlistItem> get keywordItems {
    return _watchlistItems.where((item) => item.isKeyword).toList();
  }

  List<WatchlistItem> get stockSymbolItems {
    return _watchlistItems.where((item) => item.isStockSymbol).toList();
  }

  List<CrawlSource> get activeSources {
    return _crawlSources.where((source) => source.isActive).toList();
  }

  List<CrawlSource> get inactiveSources {
    return _crawlSources.where((source) => !source.isActive).toList();
  }
}

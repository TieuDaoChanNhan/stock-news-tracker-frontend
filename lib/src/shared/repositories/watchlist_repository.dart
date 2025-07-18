import 'package:stock_tracker_app/src/shared/models/watchlist_model.dart';
import 'package:stock_tracker_app/src/shared/services/watchlist_api_service.dart';

class WatchlistRepository {
  final WatchlistApiService _apiService;

  WatchlistRepository(this._apiService);

  Future<List<WatchlistItem>> getWatchlist() async {
    return await _apiService.fetchWatchlist();
  }

  Future<WatchlistItem> addWatchlistItem(WatchlistItem item) async {
    return await _apiService.addWatchlistItem(item);
  }

  Future<void> deleteWatchlistItem(int itemId) async {
    return await _apiService.deleteWatchlistItem(itemId);
  }

  Future<List<CrawlSource>> getCrawlSources({bool? isActive}) async {
    return await _apiService.fetchCrawlSources(isActive: isActive);
  }

  Future<CrawlSource> updateCrawlSource(int sourceId, Map<String, dynamic> updateData) async {
    return await _apiService.updateCrawlSource(sourceId, updateData);
  }
}

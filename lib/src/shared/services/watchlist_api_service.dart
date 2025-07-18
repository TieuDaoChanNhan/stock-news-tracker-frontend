import 'package:dio/dio.dart';
import 'package:stock_tracker_app/src/shared/models/watchlist_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class WatchlistApiService {
  final Dio _dio;

  WatchlistApiService(this._dio);

  Future<List<WatchlistItem>> fetchWatchlist() async {
    try {
      final response = await _dio.get(AppConstants.watchlistEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WatchlistItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load watchlist: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<WatchlistItem> addWatchlistItem(WatchlistItem item) async {
    try {
      final response = await _dio.post(
        AppConstants.watchlistEndpoint,
        data: item.toCreateJson(),
      );
      
      if (response.statusCode == 201) {
        return WatchlistItem.fromJson(response.data);
      } else {
        throw Exception('Failed to add watchlist item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> deleteWatchlistItem(int itemId) async {
    try {
      final response = await _dio.delete('${AppConstants.watchlistEndpoint}/$itemId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete watchlist item: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<CrawlSource>> fetchCrawlSources({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }
      
      final response = await _dio.get(
        AppConstants.crawlSourcesEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CrawlSource.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load crawl sources: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<CrawlSource> updateCrawlSource(int sourceId, Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        '${AppConstants.crawlSourcesEndpoint}/$sourceId',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        return CrawlSource.fromJson(response.data);
      } else {
        throw Exception('Failed to update crawl source: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

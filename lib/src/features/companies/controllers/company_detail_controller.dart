import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/company_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/companies_repository.dart';

class CompanyDetailController extends GetxController {
  final CompaniesRepository _repository = Get.find<CompaniesRepository>();

  final _company = Rxn<Company>();
  final _latestMetrics = Rxn<CompanyMetrics>();
  final _metricsHistory = <CompanyMetrics>[].obs;
  final _isLoading = false.obs;
  final _isLoadingHistory = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  Company? get company => _company.value;
  CompanyMetrics? get latestMetrics => _latestMetrics.value;
  List<CompanyMetrics> get metricsHistory => _metricsHistory.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingHistory => _isLoadingHistory.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    final symbol = Get.parameters['symbol'];
    if (symbol != null) {
      loadCompanyDetail(symbol);
    }
  }

  Future<void> loadCompanyDetail(String symbol) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Load company info
      final companyResult = await _repository.getCompanyBySymbol(symbol);
      _company.value = companyResult;

      // Load latest metrics
      try {
        final latestResult = await _repository.getLatestMetrics(symbol);
        _latestMetrics.value = latestResult;
      } catch (e) {
        print('No latest metrics found for $symbol: $e');
      }

      // Load metrics history for charts
      await loadMetricsHistory(symbol);

    } catch (e) {
      _errorMessage.value = 'Failed to load company details: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMetricsHistory(String symbol, {int limit = 30}) async {
    try {
      _isLoadingHistory.value = true;
      
      final historyResult = await _repository.getCompanyMetricsHistory(
        symbol, 
        limit: limit
      );
      
      // Sắp xếp theo thời gian tăng dần cho chart
      historyResult.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      _metricsHistory.value = historyResult;
      
    } catch (e) {
      print('Failed to load metrics history for $symbol: $e');
    } finally {
      _isLoadingHistory.value = false;
    }
  }

  Future<void> fetchNewMetrics() async {
    if (_company.value == null) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await _repository.fetchMetricsForCompany(_company.value!.symbol);
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Thành công',
        result['message'] ?? 'Đã fetch metrics mới',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reload data
      await loadCompanyDetail(_company.value!.symbol);
      
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Lỗi',
        'Không thể fetch metrics mới: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleCompanyStatus() async {
    if (_company.value == null) return;

    try {
      final newStatus = !_company.value!.isActive;
      
      await _repository.updateCompany(
        _company.value!.symbol, 
        {'is_active': newStatus}
      );

      // Update local state
      _company.value = Company(
        id: _company.value!.id,
        symbol: _company.value!.symbol,
        companyName: _company.value!.companyName,
        sector: _company.value!.sector,
        industry: _company.value!.industry,
        country: _company.value!.country,
        website: _company.value!.website,
        description: _company.value!.description,
        isActive: newStatus,
        createdAt: _company.value!.createdAt,
        updatedAt: DateTime.now(),
      );

      Get.snackbar(
        'Thành công',
        'Đã ${newStatus ? "kích hoạt" : "tạm dừng"} tracking cho ${_company.value!.symbol}',
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

  // Helper methods cho chart data
  List<double> get peRatioChartData {
    return _metricsHistory
        .where((m) => m.peRatio != null)
        .map((m) => m.peRatio!)
        .toList();
  }

  List<double> get marketCapChartData {
    return _metricsHistory
        .where((m) => m.marketCap != null)
        .map((m) => m.marketCap!.toDouble())
        .toList();
  }

  List<double> get roeChartData {
    return _metricsHistory
        .where((m) => m.roe != null)
        .map((m) => m.roe!)
        .toList();
  }

  List<String> get chartLabels {
    return _metricsHistory
        .map((m) => '${m.recordedAt.day}/${m.recordedAt.month}')
        .toList();
  }

  // Quick metrics comparison
  Map<String, dynamic> get metricsComparison {
    if (_metricsHistory.length < 2) return {};
    
    final latest = _metricsHistory.last;
    final previous = _metricsHistory[_metricsHistory.length - 2];
    
    return {
      'pe_change': _calculateChange(previous.peRatio, latest.peRatio),
      'roe_change': _calculateChange(previous.roe, latest.roe),
      'market_cap_change': _calculateChange(
        previous.marketCap?.toDouble(), 
        latest.marketCap?.toDouble()
      ),
    };
  }

  double? _calculateChange(double? oldValue, double? newValue) {
    if (oldValue == null || newValue == null || oldValue == 0) return null;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_tracker_app/src/shared/models/company_model.dart';
import 'package:stock_tracker_app/src/shared/repositories/companies_repository.dart';

class CompaniesController extends GetxController {
  final CompaniesRepository _repository = Get.find<CompaniesRepository>();

  final _companies = <Company>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _showActiveOnly = true.obs;

  List<Company> get companies => _companies.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get showActiveOnly => _showActiveOnly.value;

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _repository.getCompanies(
        activeOnly: _showActiveOnly.value,
        limit: 100, // Load all companies
      );
      _companies.value = result;
    } catch (e) {
      _errorMessage.value = 'Failed to load companies: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshCompanies() async {
    await loadCompanies();
  }

  void toggleActiveFilter() {
    _showActiveOnly.value = !_showActiveOnly.value;
    loadCompanies();
  }

  Future<void> updateCompanyStatus(String symbol, bool isActive) async {
    try {
      await _repository.updateCompany(symbol, {'is_active': isActive});
      
      // Update local state
      final index = _companies.indexWhere((c) => c.symbol == symbol);
      if (index != -1) {
        _companies[index] = Company(
          id: _companies[index].id,
          symbol: _companies[index].symbol,
          companyName: _companies[index].companyName,
          sector: _companies[index].sector,
          industry: _companies[index].industry,
          country: _companies[index].country,
          website: _companies[index].website,
          description: _companies[index].description,
          isActive: isActive,
          createdAt: _companies[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _companies.refresh();
      }

      Get.snackbar(
        'Success',
        'Company status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update company status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchMetricsForCompany(String symbol) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await _repository.fetchMetricsForCompany(symbol);
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Success',
        result['message'] ?? 'Metrics fetched successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to fetch metrics: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Lấy companies grouped by sector
  Map<String, List<Company>> get companiesBySector {
    final grouped = <String, List<Company>>{};
    for (final company in companies) {
      final sector = company.sector ?? 'Unknown';
      grouped.putIfAbsent(sector, () => []).add(company);
    }
    return grouped;
  }
}

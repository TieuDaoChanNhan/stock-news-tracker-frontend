import 'package:stock_tracker_app/src/shared/models/company_model.dart';
import 'package:stock_tracker_app/src/shared/models/dashboard_model.dart';
import 'package:stock_tracker_app/src/shared/services/companies_api_service.dart';

class CompaniesRepository {
  final CompaniesApiService _apiService;

  CompaniesRepository(this._apiService);

  Future<List<Company>> getCompanies({
    int skip = 0,
    int limit = 50,
    bool activeOnly = true,
  }) async {
    return await _apiService.fetchCompanies(
      skip: skip,
      limit: limit,
      activeOnly: activeOnly,
    );
  }

  Future<Company> getCompanyBySymbol(String symbol) async {
    return await _apiService.fetchCompanyBySymbol(symbol);
  }

  Future<List<CompanyMetrics>> getCompanyMetricsHistory(
    String symbol, {
    int limit = 10,
  }) async {
    return await _apiService.fetchCompanyMetricsHistory(symbol, limit: limit);
  }

  Future<CompanyMetrics> getLatestMetrics(String symbol) async {
    return await _apiService.fetchLatestMetrics(symbol);
  }

  Future<Map<String, dynamic>> fetchMetricsForCompany(String symbol) async {
    return await _apiService.fetchMetricsForCompany(symbol);
  }

  Future<DashboardData> getDashboardOverview() async {
    return await _apiService.fetchDashboardOverview();
  }

  Future<Company> createCompany(Map<String, dynamic> companyData) async {
    return await _apiService.createCompany(companyData);
  }

  Future<Company> updateCompany(String symbol, Map<String, dynamic> updateData) async {
    return await _apiService.updateCompany(symbol, updateData);
  }

  Future<void> deleteCompany(String symbol) async {
    return await _apiService.deleteCompany(symbol);
  }
}

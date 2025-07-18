import 'package:dio/dio.dart';
import 'package:stock_tracker_app/src/shared/models/company_model.dart';
import 'package:stock_tracker_app/src/shared/models/dashboard_model.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';

class CompaniesApiService {
  final Dio _dio;

  CompaniesApiService(this._dio);

  Future<List<Company>> fetchCompanies({
    int skip = 0,
    int limit = 50,
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.companiesEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
          'active_only': activeOnly,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Company.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Company> fetchCompanyBySymbol(String symbol) async {
    try {
      final response = await _dio.get('${AppConstants.companiesEndpoint}/$symbol');
      
      if (response.statusCode == 200) {
        return Company.fromJson(response.data);
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<CompanyMetrics>> fetchCompanyMetricsHistory(
    String symbol, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.companiesEndpoint}/$symbol/metrics',
        queryParameters: {'limit': limit},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CompanyMetrics.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load company metrics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<CompanyMetrics> fetchLatestMetrics(String symbol) async {
    try {
      final response = await _dio.get(
        '${AppConstants.companiesEndpoint}/$symbol/metrics/latest'
      );
      
      if (response.statusCode == 200) {
        return CompanyMetrics.fromJson(response.data);
      } else {
        throw Exception('Failed to load latest metrics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMetricsForCompany(String symbol) async {
    try {
      final response = await _dio.post(
        '${AppConstants.companiesEndpoint}/$symbol/fetch-metrics'
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch metrics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<DashboardData> fetchDashboardOverview() async {
    try {
      final response = await _dio.get(AppConstants.companiesDashboardEndpoint);
      
      if (response.statusCode == 200) {
        return DashboardData.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Company> createCompany(Map<String, dynamic> companyData) async {
    try {
      final response = await _dio.post(
        AppConstants.companiesEndpoint,
        data: companyData,
      );
      
      if (response.statusCode == 201) {
        return Company.fromJson(response.data);
      } else {
        throw Exception('Failed to create company: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Company> updateCompany(String symbol, Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        '${AppConstants.companiesEndpoint}/$symbol',
        data: updateData,
      );
      
      if (response.statusCode == 200) {
        return Company.fromJson(response.data);
      } else {
        throw Exception('Failed to update company: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> deleteCompany(String symbol) async {
    try {
      final response = await _dio.delete('${AppConstants.companiesEndpoint}/$symbol');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete company: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

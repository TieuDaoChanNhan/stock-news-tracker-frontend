// Model cho dashboard overview API
class DashboardData {
  final int totalCompanies;
  final int companiesWithData;
  final int companiesWithoutData;
  final int apiUsageToday;
  final int apiLimit;
  final List<CompanySummary> companies;

  DashboardData({
    required this.totalCompanies,
    required this.companiesWithData,
    required this.companiesWithoutData,
    required this.apiUsageToday,
    required this.apiLimit,
    required this.companies,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCompanies: json['total_companies'],
      companiesWithData: json['companies_with_data'],
      companiesWithoutData: json['companies_without_data'],
      apiUsageToday: json['api_usage_today'],
      apiLimit: json['api_limit'],
      companies: (json['companies'] as List)
          .map((e) => CompanySummary.fromJson(e))
          .toList(),
    );
  }

  double get apiUsagePercentage => 
      apiLimit > 0 ? (apiUsageToday / apiLimit) * 100 : 0;
}

class CompanySummary {
  final String symbol;
  final String companyName;
  final String? sector;
  final bool isActive;
  final DateTime? lastUpdated;
  final double? peRatio;
  final int? marketCap;

  CompanySummary({
    required this.symbol,
    required this.companyName,
    this.sector,
    required this.isActive,
    this.lastUpdated,
    this.peRatio,
    this.marketCap,
  });

  factory CompanySummary.fromJson(Map<String, dynamic> json) {
    return CompanySummary(
      symbol: json['symbol'],
      companyName: json['company_name'],
      sector: json['sector'],
      isActive: json['is_active'],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      peRatio: json['pe_ratio']?.toDouble(),
      marketCap: json['market_cap'],
    );
  }
}

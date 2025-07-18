class Company {
  final int id;
  final String symbol;
  final String companyName;
  final String? sector;
  final String? industry;
  final String country;
  final String? website;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.id,
    required this.symbol,
    required this.companyName,
    this.sector,
    this.industry,
    this.country = 'US',
    this.website,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      symbol: json['symbol'],
      companyName: json['company_name'],
      sector: json['sector'],
      industry: json['industry'],
      country: json['country'] ?? 'US',
      website: json['website'],
      description: json['description'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'company_name': companyName,
      'sector': sector,
      'industry': industry,
      'country': country,
      'website': website,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CompanyMetrics {
  final int id;
  final int companyId;
  final String symbol;
  final double? peRatio;
  final double? pbRatio;
  final double? priceToSalesRatio;
  final int? marketCap;
  final double? eps;
  final int? revenue;
  final int? netIncome;
  final double? roe;
  final double? roa;
  final int? grossProfit;
  final int? operatingIncome;
  final int? ebitda;
  final double? debtToEquity;
  final double? currentRatio;
  final double? quickRatio;
  final double? cashRatio;
  final double? debtRatio;
  final double? grossProfitMargin;
  final double? operatingProfitMargin;
  final double? netProfitMargin;
  final double? operatingCashFlowRatio;
  final int? sharesOutstanding;
  final double? revenuePerShare;
  final double? netIncomePerShare;
  final String dataSource;
  final DateTime recordedAt;
  final DateTime createdAt;

  CompanyMetrics({
    required this.id,
    required this.companyId,
    required this.symbol,
    this.peRatio,
    this.pbRatio,
    this.priceToSalesRatio,
    this.marketCap,
    this.eps,
    this.revenue,
    this.netIncome,
    this.roe,
    this.roa,
    this.grossProfit,
    this.operatingIncome,
    this.ebitda,
    this.debtToEquity,
    this.currentRatio,
    this.quickRatio,
    this.cashRatio,
    this.debtRatio,
    this.grossProfitMargin,
    this.operatingProfitMargin,
    this.netProfitMargin,
    this.operatingCashFlowRatio,
    this.sharesOutstanding,
    this.revenuePerShare,
    this.netIncomePerShare,
    this.dataSource = 'FMP',
    required this.recordedAt,
    required this.createdAt,
  });

  factory CompanyMetrics.fromJson(Map<String, dynamic> json) {
    return CompanyMetrics(
      id: json['id'],
      companyId: json['company_id'],
      symbol: json['symbol'],
      peRatio: json['pe_ratio']?.toDouble(),
      pbRatio: json['pb_ratio']?.toDouble(),
      priceToSalesRatio: json['price_to_sales_ratio']?.toDouble(),
      marketCap: json['market_cap'],
      eps: json['eps']?.toDouble(),
      revenue: json['revenue'],
      netIncome: json['net_income'],
      roe: json['roe']?.toDouble(),
      roa: json['roa']?.toDouble(),
      grossProfit: json['gross_profit'],
      operatingIncome: json['operating_income'],
      ebitda: json['ebitda'],
      debtToEquity: json['debt_to_equity']?.toDouble(),
      currentRatio: json['current_ratio']?.toDouble(),
      quickRatio: json['quick_ratio']?.toDouble(),
      cashRatio: json['cash_ratio']?.toDouble(),
      debtRatio: json['debt_ratio']?.toDouble(),
      grossProfitMargin: json['gross_profit_margin']?.toDouble(),
      operatingProfitMargin: json['operating_profit_margin']?.toDouble(),
      netProfitMargin: json['net_profit_margin']?.toDouble(),
      operatingCashFlowRatio: json['operating_cash_flow_ratio']?.toDouble(),
      sharesOutstanding: json['shares_outstanding'],
      revenuePerShare: json['revenue_per_share']?.toDouble(),
      netIncomePerShare: json['net_income_per_share']?.toDouble(),
      dataSource: json['data_source'] ?? 'FMP',
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedMarketCap {
    if (marketCap == null) return 'N/A';
    if (marketCap! >= 1000000000) {
      return '\$${(marketCap! / 1000000000).toStringAsFixed(1)}B';
    } else if (marketCap! >= 1000000) {
      return '\$${(marketCap! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${marketCap}';
  }

  String get formattedRevenue {
    if (revenue == null) return 'N/A';
    if (revenue! >= 1000000000) {
      return '\$${(revenue! / 1000000000).toStringAsFixed(1)}B';
    } else if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${revenue}';
  }
}

// Data class để combine company với latest metrics (từ dashboard API)
class CompanyWithMetrics {
  final Company company;
  final CompanyMetrics? latestMetrics;

  CompanyWithMetrics({
    required this.company,
    this.latestMetrics,
  });

  factory CompanyWithMetrics.fromJson(Map<String, dynamic> json) {
    return CompanyWithMetrics(
      company: Company.fromJson(json['company']),
      latestMetrics: json['latest_metrics'] != null 
          ? CompanyMetrics.fromJson(json['latest_metrics'])
          : null,
    );
  }
}

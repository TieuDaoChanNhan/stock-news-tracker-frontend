class AppConstants {
  static const String appName = 'Stock News Tracking System';
  
  // ✅ SỬA: Sử dụng Railway URL
  static const String baseUrl = 'http://stock-news.local:8081/api/v1';
  
  // ✅ THÊM: Fallback URL cho development
  static const String devBaseUrl = 'http://localhost:8000/api/v1';
  
  // ✅ THÊM: Method để get correct URL based on environment
  static String get apiBaseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? baseUrl : devBaseUrl;
  }
  
  // User ID cố định (như backend)
  static const String userId = 'ong_x';
  
  // API Endpoints (dựa trên backend thực tế)
  static const String articlesEndpoint = '/articles';
  static const String articlesCountEndpoint = '/articles/count';
  static const String companiesEndpoint = '/companies';
  static const String companiesDashboardEndpoint = '/companies/overview/dashboard';
  static const String watchlistEndpoint = '/users/${userId}/watchlist';
  static const String crawlSourcesEndpoint = '/crawl-sources';
  static const String aiAnalysisEndpoint = '/ai-analysis';
  
  // Pagination
  static const int defaultLimit = 20;
  static const int defaultSkip = 0;
  
  // Colors
  static const primaryColor = 0xFF2196F3;
  static const secondaryColor = 0xFF03DAC6;
  static const errorColor = 0xFFB00020;
  static const successColor = 0xFF4CAF50;
  
  // Category colors (cho AI analysis)
  static const Map<String, int> categoryColors = {
    'Địa chính trị': 0xFFE57373,
    'Chính sách tiền tệ': 0xFF81C784,
    'Chính sách tài khóa': 0xFF64B5F6,
    'Giá vàng': 0xFFFFD54F,
    'Tỷ giá USD': 0xFFBA68C8,
    'Tin tức doanh nghiệp': 0xFF4DB6AC,
    'Thị trường chung': 0xFF90A4AE,
    'Không liên quan': 0xFFBCBCBC,
  };
}

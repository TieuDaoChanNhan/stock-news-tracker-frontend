enum Environment { development, staging, production }

class Config {
  static const Environment _environment = Environment.development;

  static Environment get environment => _environment;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return "http://stock-news.local:8082/api/v1";
      case Environment.staging:
        return "http://stock-news.local:8082/api/v1";
      case Environment.production:
        return "http://stock-news.local:8082/api/v1";
    }
  }

  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get enableLogging => !isProduction;
  
  static Duration get apiTimeout {
    return isProduction 
        ? const Duration(seconds: 60)
        : const Duration(seconds: 10);
  }

  static int get paginationLimit => 20;
  static Duration get cacheMaxAge => const Duration(hours: 1);
}

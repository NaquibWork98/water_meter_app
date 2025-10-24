class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://your-api-url.com/api';
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String getMeterEndpoint = '/meters';
  static const String submitReadingEndpoint = '/readings';
  static const String readingHistoryEndpoint = '/readings/history';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String cachedReadingsKey = 'cached_readings';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 85;
}
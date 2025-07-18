import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException: $message';
}

class ApiHelper {
  static void handleError(dynamic error) {
    String message = 'Đã xảy ra lỗi không xác định';
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Kết nối timeout. Vui lòng thử lại.';
          break;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 404) {
            message = 'Không tìm thấy dữ liệu.';
          } else if (error.response?.statusCode == 500) {
            message = 'Lỗi server. Vui lòng thử lại sau.';
          } else {
            message = 'Lỗi HTTP ${error.response?.statusCode}';
          }
          break;
        case DioExceptionType.connectionError:
          message = 'Không thể kết nối đến server. Kiểm tra kết nối mạng.';
          break;
        default:
          message = error.message ?? 'Lỗi không xác định';
      }
    } else if (error is ApiException) {
      message = error.message;
    } else {
      message = error.toString();
    }

    Get.snackbar(
      'Lỗi',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Thành công',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Thông tin',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.surfaceVariant,
      colorText: Get.theme.colorScheme.onSurfaceVariant,
      duration: const Duration(seconds: 3),
    );
  }
}

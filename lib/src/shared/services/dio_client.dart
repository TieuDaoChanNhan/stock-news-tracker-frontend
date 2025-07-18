import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:stock_tracker_app/src/shared/utils/app_constants.dart';
import 'package:stock_tracker_app/src/shared/utils/config.dart';
import 'package:stock_tracker_app/src/shared/utils/debug_helper.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: Config.apiTimeout,
      receiveTimeout: Config.apiTimeout,
      sendTimeout: Config.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Only add logging interceptor in development
    if (Config.enableLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (object) {
          DebugHelper.log(object.toString(), tag: 'DIO');
        },
      ));
    }

    // Error handling interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        DebugHelper.logError('Dio Error: ${error.message}', tag: 'DIO');
        return handler.next(error);
      },
    ));

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    return dio;
  }
}
import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../core/services/app_storage_service.dart';
import '../core/utils/toast_util.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle common response format
          final data = response.data;
          if (data != null && data is Map<String, dynamic>) {
            if (data['code'] != null && data['code'] != 0) {
              // 统一处理业务错误
              final msg = data['message'] ?? '业务请求失败';
              ToastUtil.error(msg);
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: msg,
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Global error handling
          String errorMessage = '网络请求异常';
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = '网络连接超时，请重试';
          } else if (e.response != null) {
            final data = e.response?.data;
            if (data != null &&
                data is Map<String, dynamic> &&
                data['message'] != null) {
              errorMessage = data['message'];
            } else if (e.response?.statusCode == 401) {
              errorMessage = '未授权或登录已过期，请重新登录';
            } else if (e.response?.statusCode == 403) {
              errorMessage = '无权访问';
            } else if (e.response?.statusCode == 500) {
              errorMessage = '服务器内部错误';
            }
          } else if (e.error != null) {
            errorMessage = e.error.toString();
          }

          ToastUtil.error(errorMessage);

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              error: errorMessage,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}

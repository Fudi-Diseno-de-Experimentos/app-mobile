import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required Dio dio}) : _dio = dio {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(
      milliseconds: ApiConstants.connectionTimeout,
    );
    _dio.options.receiveTimeout = const Duration(
      milliseconds: ApiConstants.receiveTimeout,
    );

    // Log interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  void addAuthInterceptor(AuthInterceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException error) {
    String message = 'Unexpected error occurred';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data?['message'] ?? 'Server error';
        break;
      case DioExceptionType.connectionError:
        message = 'No Internet connection';
        break;
      default:
        message = error.message ?? 'Unknown error';
        break;
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}

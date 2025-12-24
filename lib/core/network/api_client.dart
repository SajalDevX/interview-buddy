import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  String? _apiKey;

  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.groqBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log('ApiClient: Request to ${options.path}', name: 'ApiClient');
          developer.log('ApiClient: Headers: ${options.headers}', name: 'ApiClient');
          if (_apiKey != null) {
            options.headers['Authorization'] = 'Bearer $_apiKey';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          developer.log('ApiClient: Interceptor caught error: ${error.type}', name: 'ApiClient');
          developer.log('ApiClient: Error response: ${error.response?.data}', name: 'ApiClient');
          return handler.next(error);
        },
      ),
    );
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('ApiClient: POST $path', name: 'ApiClient');
    developer.log('ApiClient: API Key set: ${_apiKey != null}', name: 'ApiClient');
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      developer.log('ApiClient: Response status: ${response.statusCode}', name: 'ApiClient');
      return response;
    } on DioException catch (e) {
      developer.log('ApiClient: DioException type: ${e.type}', name: 'ApiClient');
      developer.log('ApiClient: DioException message: ${e.message}', name: 'ApiClient');
      developer.log('ApiClient: Response status: ${e.response?.statusCode}', name: 'ApiClient');
      developer.log('ApiClient: Response data: ${e.response?.data}', name: 'ApiClient');
      throw _handleError(e);
    }
  }

  Future<Response<T>> postFormData<T>(
    String path, {
    required FormData data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: options ?? Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        throw NetworkException(message: 'No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response);

        if (statusCode == 401) {
          throw AuthException(message: message);
        } else if (statusCode == 429) {
          throw RateLimitException(message: message);
        } else {
          throw ServerException(message: message, statusCode: statusCode);
        }
      default:
        throw ServerException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final error = response!.data['error'];
      if (error is Map) {
        return error['message'] ?? 'Unknown error';
      }
      return error?.toString() ?? 'Unknown error';
    }
    return 'Server error occurred';
  }
}

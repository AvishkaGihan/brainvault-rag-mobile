import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';

/// Service responsible for handling all HTTP requests to the backend API.
/// Wraps [Dio] with interceptors for authentication, logging, and error handling.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory ApiService() => _instance;

  ApiService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Auth Token
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('🌐 [API Request] ${options.method} ${options.path}');
            if (options.queryParameters.isNotEmpty) {
              print('   Params: ${options.queryParameters}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ [API Response] ${response.statusCode} ${response.requestOptions.path}',
            );
          }

          // Unwrap the standard ApiResponse format: { success, data, error }
          // We assume the backend always returns this structure for 200 OK
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('data')) {
              // Replace the response data with the actual payload
              response.data = data['data'];
            }
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print(
              '❌ [API Error] ${e.response?.statusCode} ${e.requestOptions.path}',
            );
            print('   Message: ${e.message}');
            print('   Data: ${e.response?.data}');
          }

          // If the backend returned a structured error response, extract the message
          String? serverError;
          if (e.response?.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            if (data.containsKey('error')) {
              serverError = data['error'] as String;
            }
          }

          // Create a new exception with the refined message if available
          if (serverError != null) {
            final newException = DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: serverError,
            );
            return handler.next(newException);
          }

          return handler.next(e);
        },
      ),
    );
  }

  /// Performs a GET request.
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get<T>(path, queryParameters: queryParams);
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request.
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParams,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PUT request.
  Future<T> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put<T>(path, data: data);
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request.
  Future<T> delete<T>(String path) async {
    try {
      final response = await _dio.delete<T>(path);
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Uploads a file using MultipartRequest.
  Future<T> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
  }) async {
    try {
      final String fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            print(
              '📤 Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Processes Dio errors and returns a user-friendly exception or message.
  /// Uses strict error transformation logic.
  Exception _handleError(DioException error) {
    // If the error message was already refined in the interceptor, use it
    if (error.error is String) {
      return Exception(error.error);
    }

    String message = 'An unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message =
            'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = _parseHttpError(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection available';
        break;
      default:
        message = 'Network error occurred';
    }

    return Exception(message);
  }

  String _parseHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Received invalid status code: $statusCode';
    }
  }
}

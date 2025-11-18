import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService = StorageService();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Interceptores para logging y manejo de errores
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token si existe
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('🚀 REQUEST[${options.method}] => ${options.uri}');
            print('📦 DATA: ${options.data}');
            print('🔑 HEADERS: ${options.headers}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
            print('📥 DATA: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
            print('📛 MESSAGE: ${error.message}');
            print('📛 DATA: ${error.response?.data}');
          }

          // Si el token expiró (401), cerrar sesión
          if (error.response?.statusCode == ApiConfig.statusUnauthorized) {
            await _storageService.clearAll();
            // TODO: Navegar a login
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ============================================
  // MÉTODOS HTTP
  // ============================================

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // UPLOAD DE ARCHIVOS
  // ============================================

  Future<Response> uploadFile(
      String path,
      String filePath,
      String fieldName, {
        Map<String, dynamic>? additionalData,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MANEJO DE ERRORES
  // ============================================

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de espera agotado. Verifica tu conexión a internet.',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Solicitud cancelada',
          statusCode: 0,
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return ApiException(
            message: 'Sin conexión a internet',
            statusCode: 0,
          );
        }
        return ApiException(
          message: 'Error desconocido: ${error.message}',
          statusCode: 0,
        );

      default:
        return ApiException(
          message: 'Error en la conexión',
          statusCode: 0,
        );
    }
  }

  ApiException _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = 'Error en el servidor';

    // Parsear mensaje de error según la respuesta de Laravel
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        message = data['message'];
      } else if (data.containsKey('errors')) {
        // Errores de validación (422)
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first;
        }
      }
    }

    switch (statusCode) {
      case ApiConfig.statusBadRequest:
        return ApiException(
          message: message,
          statusCode: statusCode,
        );

      case ApiConfig.statusUnauthorized:
        return ApiException(
          message: 'No autorizado. Inicia sesión nuevamente.',
          statusCode: statusCode,
        );

      case ApiConfig.statusForbidden:
        return ApiException(
          message: 'No tienes permisos para realizar esta acción',
          statusCode: statusCode,
        );

      case ApiConfig.statusNotFound:
        return ApiException(
          message: 'Recurso no encontrado',
          statusCode: statusCode,
        );

      case ApiConfig.statusUnprocessableEntity:
        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: data['errors'] as Map<String, dynamic>?,
        );

      case ApiConfig.statusTooManyRequests:
        return ApiException(
          message: 'Demasiadas solicitudes. Intenta más tarde.',
          statusCode: statusCode,
        );

      case ApiConfig.statusServerError:
        return ApiException(
          message: 'Error en el servidor. Intenta más tarde.',
          statusCode: statusCode,
        );

      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}

// ============================================
// CLASE DE EXCEPCIÓN PERSONALIZADA
// ============================================

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

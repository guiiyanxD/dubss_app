import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/usuario.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // ============================================
  // REGISTRO
  // ============================================

  Future<Map<String, dynamic>> registro({
    required String nombre,
    required String apellido,
    required String ci,
    required String email,
    required String telefono,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registro,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'ci': ci,
          'email': email,
          'telefono': telefono,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'rol': 'estudiante', // Por defecto todos son estudiantes
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        // Guardar token y datos del usuario
        final token = data['data']['token'];
        final usuarioData = data['data']['usuario'];

        await _storageService.saveToken(token);
        await _storageService.saveUserData(
          userId: usuarioData['id'],
          email: usuarioData['email'],
          name: '${usuarioData['nombre']} ${usuarioData['apellido']}',
          role: usuarioData['rol'],
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
          'usuario': Usuario.fromJson(usuarioData),
          'token': token,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error en el registro',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // LOGIN
  // ============================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (kDebugMode) {
        print('Login API Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
        };
      }

      if (data['success'] == true) {
        // Validar estructura de datos
        if (data['data'] == null) {
          return {
            'success': false,
            'message': 'Datos incompletos en la respuesta',
          };
        }

        final responseData = data['data'];
        final token = responseData['token'];
        final usuarioData = responseData['usuario'];

        if (token == null || usuarioData == null) {
          if (kDebugMode) {
            print(' Missing token or usuario in response data');
            print('Token: $token');
            print('Usuario: $usuarioData');
          }
          return {
            'success': false,
            'message': 'Token o datos de usuario no encontrados',
          };
        }

        await _storageService.saveToken(token);

        final userId = usuarioData['id'];
        final userEmail = usuarioData['email'];
        final nombre = usuarioData['nombre'];
        final apellido = usuarioData['apellido'];
        final rol = usuarioData['rol'];

        if (userId == null || userEmail == null || nombre == null || apellido == null || rol == null) {
          if (kDebugMode) {
            print('Missing required user fields');
            print('Usuario data: $usuarioData');
          }
          return {
            'success': false,
            'message': 'Datos de usuario incompletos',
          };
        }

        await _storageService.saveUserData(
          userId: userId,
          email: userEmail,
          name: '$nombre $apellido',
          role: rol,
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Login exitoso',
          'usuario': Usuario.fromJson(usuarioData),
          'token': token,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error en el login',
      };
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('ApiException in login: ${e.message}');
      }
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in login: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(ApiConfig.logout);

      // Limpiar datos locales independientemente de la respuesta
      await _storageService.clearAll();

      final data = response.data;

      return {
        'success': true,
        'message': data['message'] ?? 'Sesión cerrada exitosamente',
      };
    } on ApiException catch (e) {
      // Aún si falla la API, limpiar datos locales
      await _storageService.clearAll();

      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      // Aún si falla, limpiar datos locales
      await _storageService.clearAll();

      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // RECUPERAR CONTRASEÑA
  // ============================================

  Future<Map<String, dynamic>> recuperarPassword({
    required String email,
  }) async {
    try {
      // TODO: Implementar endpoint en el backend
      // Por ahora retornamos simulación
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'message': 'Se han enviado las instrucciones a tu correo',
      };

      /*
      // Código real cuando el endpoint esté disponible:
      final response = await _apiService.post(
        ApiConfig.recuperarPassword,
        data: {
          'email': email,
        },
      );

      final data = response.data;

      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Correo enviado',
      };
      */
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // OBTENER PERFIL
  // ============================================

  Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      final response = await _apiService.get(ApiConfig.perfil);

      final data = response.data;

      if (data['success'] == true) {
        final usuarioData = data['data'];

        // Actualizar datos locales
        await _storageService.saveUserData(
          userId: usuarioData['id'],
          email: usuarioData['email'],
          name: '${usuarioData['nombre']} ${usuarioData['apellido']}',
          role: usuarioData['rol'],
        );

        return {
          'success': true,
          'usuario': Usuario.fromJson(usuarioData),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener perfil',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // ACTUALIZAR PERFIL
  // ============================================

  Future<Map<String, dynamic>> actualizarPerfil({
    String? nombre,
    String? apellido,
    String? telefono,
    String? passwordActual,
    String? passwordNuevo,
  }) async {
    try {
      final Map<String, dynamic> requestData = {};

      if (nombre != null) requestData['nombre'] = nombre;
      if (apellido != null) requestData['apellido'] = apellido;
      if (telefono != null) requestData['telefono'] = telefono;
      if (passwordActual != null && passwordNuevo != null) {
        requestData['password_actual'] = passwordActual;
        requestData['password_nuevo'] = passwordNuevo;
      }

      final response = await _apiService.put(
        ApiConfig.actualizarPerfil,
        data: requestData,
      );

      final data = response.data;

      if (data['success'] == true) {
        final usuarioData = data['data'];

        // Actualizar datos locales
        await _storageService.saveUserData(
          userId: usuarioData['id'],
          email: usuarioData['email'],
          name: '${usuarioData['nombre']} ${usuarioData['apellido']}',
          role: usuarioData['rol'],
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Perfil actualizado',
          'usuario': Usuario.fromJson(usuarioData),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al actualizar perfil',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // VERIFICAR SESIÓN
  // ============================================

  Future<bool> verificarSesion() async {
    try {
      final hasToken = await _storageService.hasToken();
      if (!hasToken) return false;

      // Verificar que el token sea válido
      final result = await obtenerPerfil();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // VERIFICAR SI ESTÁ LOGUEADO
  // ============================================

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }
}
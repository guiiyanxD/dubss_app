import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  // Servicios
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // Estado
  AuthStatus _status = AuthStatus.initial;
  Usuario? _usuario;
  String? _token;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  Usuario? get usuario => _usuario;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;


  /// Verifica si hay una sesión activa al iniciar la app
  Future<void> checkAuthStatus() async {
    try {
      _setStatus(AuthStatus.loading);

      final hasToken = await _storageService.hasToken();

      if (!hasToken) {
        _setStatus(AuthStatus.unauthenticated);
        return;
      }

      // Verificar que el token sea válido obteniendo el perfil
      final result = await _authService.obtenerPerfil();

      if (result['success'] == true) {
        _usuario = result['usuario'];
        _token = await _storageService.getToken();
        _setStatus(AuthStatus.authenticated);
      } else {

        // Token inválido, limpiar datos
        await _storageService.clearAll();
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      await _storageService.clearAll();
      _setStatus(AuthStatus.unauthenticated);
    }
  }


  Future<bool> registro({
    required String nombre,
    required String apellido,
    required String ci,
    required String email,
    required String telefono,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _clearError();

      final result = await _authService.registro(
        nombre: nombre,
        apellido: apellido,
        ci: ci,
        email: email,
        telefono: telefono,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result['success'] == true) {
        _usuario = result['usuario'];
        _token = result['token'];
        _setStatus(AuthStatus.authenticated);
        return true;
      } else {
        _errorMessage = result['message'];
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error en el registro: $e';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _clearError();

      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print(' Login result: $result');
      }

      if (result['success'] == true) {
        // Validar que los datos existan antes de asignar
        if (result['usuario'] != null && result['token'] != null) {
          _usuario = result['usuario'] as Usuario;
          _token = result['token'] as String;
          _setStatus(AuthStatus.authenticated);
          return true;
        } else {
          _errorMessage = 'Datos de usuario incompletos';
          if (kDebugMode) {
            print(' Missing usuario or token in response');
          }
          _setStatus(AuthStatus.unauthenticated);
          return false;
        }
      } else {
        _errorMessage = result['message'] ?? 'Error desconocido en el login';
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error en el login: $e';
      if (kDebugMode) {
        print(' Login error: $e');
      }
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }


  Future<void> logout() async {
    try {
      _setStatus(AuthStatus.loading);

      // Llamar a la API para invalidar el token
      await _authService.logout();

      // Limpiar estado local
      _usuario = null;
      _token = null;
      _clearError();

      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }

      // Aunque falle la API, limpiar localmente
      _usuario = null;
      _token = null;
      _clearError();
      _setStatus(AuthStatus.unauthenticated);
    }
  }


  Future<bool> actualizarPerfil({
    String? nombre,
    String? apellido,
    String? telefono,
    String? passwordActual,
    String? passwordNuevo,
  }) async {
    try {
      _clearError();

      final result = await _authService.actualizarPerfil(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        passwordActual: passwordActual,
        passwordNuevo: passwordNuevo,
      );

      if (result['success'] == true) {
        _usuario = result['usuario'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }


  Future<void> recargarPerfil() async {
    try {
      final result = await _authService.obtenerPerfil();

      if (result['success'] == true) {
        _usuario = result['usuario'];
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reloading profile: $e');
      }
    }
  }


  Future<bool> recuperarPassword({required String email}) async {
    try {
      _clearError();

      final result = await _authService.recuperarPassword(email: email);

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al recuperar contraseña: $e';
      notifyListeners();
      return false;
    }
  }


  String get nombreCompleto => _usuario?.nombreCompleto ?? '';
  String get email => _usuario?.email ?? '';
  String get rol => _usuario?.rol ?? '';
  bool get esEstudiante => _usuario?.esEstudiante ?? false;
  bool get esOperador => _usuario?.esOperador ?? false;
  bool get esAdmin => _usuario?.esAdmin ?? false;



  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }


  @override
  void dispose() {
    super.dispose();
  }
}
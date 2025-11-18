/*import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  Usuario? _usuario;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Usuario? get usuario => _usuario;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _usuario != null && _token != null;

  /// Verificar si hay sesión activa
  Future<bool> checkAuthStatus() async {
    try {
      _token = await _storage.getToken();

      if (_token != null) {
        // Obtener datos del usuario
        final userData = await _storage.getUserData();
        if (userData != null) {
          _usuario = Usuario.fromJson(userData);
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        _token = response['data']['token'];
        _usuario = Usuario.fromJson(response['data']['usuario']);

        // Guardar en storage
        await _storage.saveToken(_token!);
        await _storage.saveUserData(response['data']['usuario']);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error en el login';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu internet.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro
  Future<bool> registro({
    required String nombre,
    required String apellido,
    required String ci,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.registro(
        nombre: nombre,
        apellido: apellido,
        ci: ci,
        email: email,
        password: password,
        telefono: telefono,
      );

      if (response['success'] == true) {
        _token = response['data']['token'];
        _usuario = Usuario.fromJson(response['data']['usuario']);

        await _storage.saveToken(_token!);
        await _storage.saveUserData(response['data']['usuario']);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error en el registro';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu internet.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      // Continuar con logout local aunque falle la API
    } finally {
      _usuario = null;
      _token = null;
      await _storage.clearAll();
      notifyListeners();
    }
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}*/
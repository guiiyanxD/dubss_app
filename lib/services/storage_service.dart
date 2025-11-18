import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Storage seguro para datos sensibles (token)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Shared Preferences para datos no sensibles
  SharedPreferences? _prefs;

  // ============================================
  // KEYS
  // ============================================

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  // ============================================
  // INICIALIZACIÓN
  // ============================================

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============================================
  // MÉTODOS DE AUTENTICACIÓN
  // ============================================

  // Guardar token de autenticación
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  // Verificar si hay token guardado
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Eliminar token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // ============================================
  // DATOS DE USUARIO
  // ============================================

  // Guardar datos completos del usuario
  Future<void> saveUserData({
    required int userId,
    required String email,
    required String name,
    required String role,
  }) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserRole, role);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Obtener ID del usuario
  Future<int?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyUserId);
  }

  // Obtener email del usuario
  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserEmail);
  }

  // Obtener nombre del usuario
  Future<String?> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserName);
  }

  // Obtener rol del usuario
  Future<String?> getUserRole() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserRole);
  }

  // Verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ============================================
  // FIREBASE FCM TOKEN
  // ============================================

  Future<void> saveFcmToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_keyFcmToken, token);
  }

  Future<String?> getFcmToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyFcmToken);
  }

  // ============================================
  // CONFIGURACIÓN DE LA APP
  // ============================================

  // Tema (dark/light)
  Future<void> setThemeMode(String mode) async {
    final prefs = await _preferences;
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  // Idioma
  Future<void> setLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(_keyLanguage, languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(_keyLanguage) ?? 'es';
  }

  // ============================================
  // LIMPIAR DATOS
  // ============================================

  // Limpiar todos los datos (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await _preferences;
    await prefs.clear();
  }

  // Limpiar solo datos de autenticación
  Future<void> clearAuthData() async {
    await deleteToken();
    final prefs = await _preferences;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserRole);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // ============================================
  // MÉTODOS GENÉRICOS
  // ============================================

  // Guardar string
  Future<void> saveString(String key, String value) async {
    final prefs = await _preferences;
    await prefs.setString(key, value);
  }

  // Obtener string
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  // Guardar int
  Future<void> saveInt(String key, int value) async {
    final prefs = await _preferences;
    await prefs.setInt(key, value);
  }

  // Obtener int
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  // Guardar bool
  Future<void> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(key, value);
  }

  // Obtener bool
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  // Eliminar un key específico
  Future<void> remove(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }
}
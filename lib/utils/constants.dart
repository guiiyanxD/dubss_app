class Constants {

  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';

  // Validaciones
  static const int minPasswordLength = 8;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Mensajes
  static const String msgNoInternet = 'No hay conexión a internet';
  static const String msgError = 'Ocurrió un error. Inténtalo de nuevo.';
  static const String msgSuccess = 'Operación exitosa';
}
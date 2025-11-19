class ApiConfig {
  // ============================================
  // CONFIGURACIÓN DE ENDPOINTS
  // ============================================

  // Cambiar según tu entorno
  static const String _baseUrlProduction = 'https://qcs3wqh6-8000.brs.devtunnels.ms';
  static const String _baseUrlDevelopment = 'http://10.0.2.2:8000'; // Emulador Android
  // static const String _baseUrlDevelopment = 'http://localhost:8000'; // iOS Simulator

  // Cambiar a true cuando estés en producción
  static const bool isProduction = false;

  static String get baseUrl => isProduction ? _baseUrlProduction : _baseUrlDevelopment;
  static String get apiVersion => '/api/v1';
  static String get apiUrl => '$baseUrl$apiVersion';

  // ============================================
  // ENDPOINTS DE AUTENTICACIÓN
  // ============================================

  static String get registro => '$apiUrl/registro';
  static String get login => '$apiUrl/login';
  static String get logout => '$apiUrl/logout';
  static String get perfil => '$apiUrl/perfil';
  static String get actualizarPerfil => '$apiUrl/perfil';

  // ============================================
  // ENDPOINTS DE CONVOCATORIAS
  // ============================================

  static String get convocatorias => '$apiUrl/convocatorias';
  static String convocatoriaDetalle(int id) => '$apiUrl/convocatorias/$id';

  // ============================================
  // ENDPOINTS DE TURNOS
  // ============================================

  static String get turnosDisponibles => '$apiUrl/turnos/disponibles';
  static String get reservarTurno => '$apiUrl/turnos/reservar';
  static String get misTurnos => '$apiUrl/turnos/mis-turnos';
  static String cancelarTurno(int id) => '$apiUrl/turnos/$id/cancelar';

  // ============================================
  // ENDPOINTS DE TRÁMITES
  // ============================================

  static String get tramites => '$apiUrl/tramites';
  static String tramiteDetalle(int id) => '$apiUrl/tramites/$id';
  static String get crearTramite => '$apiUrl/tramites';
  static String subirDocumento(int id) => '$apiUrl/tramites/$id/documentos';
  static String apelarTramite(int id) => '$apiUrl/tramites/$id/apelar';

  // ============================================
  // ENDPOINTS DE NOTIFICACIONES
  // ============================================

  static String get notificaciones => '$apiUrl/notificaciones';
  static String get notificacionesNoLeidas => '$apiUrl/notificaciones/no-leidas';
  static String marcarLeida(int id) => '$apiUrl/notificaciones/$id/leer';
  static String get leerTodas => '$apiUrl/notificaciones/leer-todas';

  // ============================================
  // CONFIGURACIÓN DE TIMEOUTS
  // ============================================

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ============================================
  // HEADERS
  // ============================================

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithToken(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  // ============================================
  // CÓDIGOS DE RESPUESTA
  // ============================================

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusServerError = 500;
}
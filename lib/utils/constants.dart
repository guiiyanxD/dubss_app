import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppConstants {
  // ============================================
  // INFORMACIÓN DE LA APP
  // ============================================

  static const String appName = 'DUBSS';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de Gestión de Becas Universitarias';
  static const String organization = 'Universidad Autónoma Gabriel René Moreno';
  static const String department = 'Dirección Universitaria de Bienestar Social y Salud';

  // ============================================
  // CONTACTO Y SOPORTE
  // ============================================

  static const String supportEmail = 'soporte@dubss.edu.bo';
  static const String supportPhone = '+591 3 1234567';
  static const String address = 'Av. Busch, Santa Cruz de la Sierra';

  // Horarios de atención
  static const String workingDays = 'Lunes a Viernes';
  static const String workingHours = '8:00 AM - 6:00 PM';

  // ============================================
  // ROLES DE USUARIO
  // ============================================

  static const String roleEstudiante = 'estudiante';
  static const String roleOperador = 'operador';
  static const String roleAdmin = 'admin';

  // ============================================
  // ESTADOS DE TRÁMITES
  // ============================================

  static const String estadoSolicitado = 'SOLICITADO';
  static const String estadoRecepcionado = 'RECEPCIONADO';
  static const String estadoEnRevision = 'EN_REVISION';
  static const String estadoDocumentosObservados = 'DOCUMENTOS_OBSERVADOS';
  static const String estadoRevisionCompletada = 'REVISION_COMPLETADA';
  static const String estadoAprobado = 'APROBADO';
  static const String estadoRechazado = 'RECHAZADO';
  static const String estadoEnApelacion = 'EN_APELACION';

  // Colores por estado
  static const Map<String, Color> estadoColors = {
    'SOLICITADO': Color(0xFF2196F3), // Azul
    'RECEPCIONADO': Color(0xFF9C27B0), // Púrpura
    'EN_REVISION': Color(0xFFFF9800), // Naranja
    'DOCUMENTOS_OBSERVADOS': Color(0xFFE53935), // Rojo
    'REVISION_COMPLETADA': Color(0xFF43A047), // Verde
    'APROBADO': Color(0xFF4CAF50), // Verde oscuro
    'RECHAZADO': Color(0xFFD32F2F), // Rojo oscuro
    'EN_APELACION': Color(0xFFFFC107), // Amarillo
  };

  // Iconos por estado
  static const Map<String, IconData> estadoIcons = {
    'SOLICITADO': Icons.send,
    'RECEPCIONADO': Icons.inbox,
    'EN_REVISION': Icons.rate_review,
    'DOCUMENTOS_OBSERVADOS': Icons.warning,
    'REVISION_COMPLETADA': Icons.check_circle,
    'APROBADO': Icons.thumb_up,
    'RECHAZADO': Icons.thumb_down,
    'EN_APELACION': Icons.gavel,
  };

  // ============================================
  // TIPOS DE BECAS
  // ============================================

  static const String becaSocioeconomica = 'socioeconomica';
  static const String becaAcademica = 'academica';
  static const String becaExtension = 'extension';

  static const Map<String, String> tiposBecaNombres = {
    'socioeconomica': 'Beca Socioeconómica',
    'academica': 'Beca Académica',
    'extension': 'Beca de Extensión',
  };

  static const Map<String, IconData> tiposBecaIcons = {
    'socioeconomica': Icons.attach_money,
    'academica': Icons.school,
    'extension': Icons.local_library,
  };

  // ============================================
  // ESTADOS DE TURNOS
  // ============================================

  static const String turnoReservado = 'reservado';
  static const String turnoAtendido = 'atendido';
  static const String turnoCancelado = 'cancelado';
  static const String turnoVencido = 'vencido';

  // ============================================
  // FORMATOS DE ARCHIVO
  // ============================================

  static const List<String> allowedFileExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const String maxFileSizeReadable = '10 MB';

  // ============================================
  // VALIDACIONES
  // ============================================

  static const int minPasswordLength = 8;
  static const int minCiLength = 6;
  static const int minPhoneLength = 8;

  // ============================================
  // PAGINACIÓN
  // ============================================

  static const int itemsPerPage = 15;
  static const int itemsPerPageGrid = 12;

  // ============================================
  // DURACIÓN DE ANIMACIONES
  // ============================================

  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ============================================
  // MENSAJES COMUNES
  // ============================================

  static const String msgNoInternet = 'Sin conexión a internet';
  static const String msgServerError = 'Error en el servidor. Intenta más tarde.';
  static const String msgTimeout = 'Tiempo de espera agotado';
  static const String msgUnknownError = 'Error desconocido. Intenta nuevamente.';
  static const String msgSuccessOperation = 'Operación exitosa';
  static const String msgConfirmLogout = '¿Estás seguro que deseas cerrar sesión?';

  // ============================================
  // REGEX PATTERNS
  // ============================================

  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^\d{8,15}$',
  );

  static final RegExp ciRegex = RegExp(
    r'^\d{6,10}$',
  );

  // ============================================
  // URLs ÚTILES
  // ============================================

  static const String websiteUrl = 'https://www.uagrm.edu.bo';
  static const String facebookUrl = 'https://facebook.com/uagrm';
  static const String instagramUrl = 'https://instagram.com/uagrm';
  static const String privacyPolicyUrl = 'https://dubss.edu.bo/privacy';
  static const String termsUrl = 'https://dubss.edu.bo/terms';
}

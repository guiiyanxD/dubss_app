import 'package:flutter/material.dart';
import 'constants.dart';
class AppHelpers {

  /**
   * Color del estado
   */
  static Color getEstadoColor(String estado) {
    return AppConstants.estadoColors[estado] ?? Colors.grey;
  }

  /**
   * iconos del estado
   */
  static IconData getEstadoIcon(String estado) {
    return AppConstants.estadoIcons[estado] ?? Icons.help_outline;
  }

  // Obtener nombre de tipo de beca
  static String getTipoBecaNombre(String tipo) {
    return AppConstants.tiposBecaNombres[tipo] ?? tipo;
  }

  // Obtener icono de tipo de beca
  static IconData getTipoBecaIcon(String tipo) {
    return AppConstants.tiposBecaIcons[tipo] ?? Icons.card_giftcard;
  }

  // Formatear tamaño de archivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Validar formato de email
  static bool isValidEmail(String email) {
    return AppConstants.emailRegex.hasMatch(email);
  }

  // Validar formato de teléfono
  static bool isValidPhone(String phone) {
    return AppConstants.phoneRegex.hasMatch(phone);
  }

  // Validar formato de CI
  static bool isValidCI(String ci) {
    return AppConstants.ciRegex.hasMatch(ci);
  }

  // Formatear fecha
  static String formatFecha(DateTime fecha, {String format = 'dd/MM/yyyy'}) {
    final day = fecha.day.toString().padLeft(2, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final year = fecha.year.toString();

    if (format == 'dd/MM/yyyy') {
      return '$day/$month/$year';
    } else if (format == 'yyyy-MM-dd') {
      return '$year-$month-$day';
    }
    return '$day/$month/$year';
  }

  // Obtener iniciales de un nombre
  static String getIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  // Tiempo relativo (hace X tiempo)
  static String tiempoRelativo(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.inDays > 365) {
      final years = (diferencia.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? "año" : "años"}';
    }
    if (diferencia.inDays > 30) {
      final months = (diferencia.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? "mes" : "meses"}';
    }
    if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} ${diferencia.inDays == 1 ? "día" : "días"}';
    }
    if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} ${diferencia.inHours == 1 ? "hora" : "horas"}';
    }
    if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} ${diferencia.inMinutes == 1 ? "minuto" : "minutos"}';
    }
    return 'Ahora mismo';
  }
}
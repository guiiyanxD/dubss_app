// services/turno_service.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/turno.dart';
import '../models/slot_turno.dart';
import 'api_service.dart';


class TurnoService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> obtenerTurnosDisponibles({
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);

      final response = await _apiService.get(
        ApiConfig.turnosDisponibles,
        queryParameters: {'fecha': fechaStr},
      );

      if (kDebugMode) {
        print('📅 Turnos Disponibles Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
          'slots': <SlotDisponible>[],
        };
      }

      if (data['success'] == true) {
        final List<dynamic> slotsData = data['data'] ?? [];

        final List<SlotDisponible> slots = slotsData
            .map((json) => SlotDisponible.fromJson(json))
            .toList();

        return {
          'success': true,
          'slots': slots,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener turnos disponibles',
        'slots': <SlotDisponible>[],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerTurnosDisponibles: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
        'slots': <SlotDisponible>[],
      };
    }
  }

  // ============================================
  // RESERVAR TURNO
  // ============================================

  Future<Map<String, dynamic>> reservarTurno({
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    try {
      final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);

      final response = await _apiService.post(
        ApiConfig.reservarTurno,
        data: {
          'fecha': fechaStr,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
        },
      );

      if (kDebugMode) {
        print('📅 Reservar Turno Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
        };
      }

      if (data['success'] == true) {
        final turnoData = data['data'];

        return {
          'success': true,
          'turno': Turno.fromJson(turnoData),
          'message': data['message'] ?? 'Turno reservado exitosamente',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al reservar turno',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en reservarTurno: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  // ============================================
  // OBTENER MIS TURNOS
  // ============================================

  Future<Map<String, dynamic>> obtenerMisTurnos() async {
    try {
      final response = await _apiService.get(ApiConfig.misTurnos);

      if (kDebugMode) {
        print('📅 Mis Turnos Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
          'turnos': <Turno>[],
        };
      }

      if (data['success'] == true) {
        final List<dynamic> turnosData = data['data'] ?? [];

        final List<Turno> turnos = turnosData
            .map((json) => Turno.fromJson(json))
            .toList();

        // Ordenar por fecha más reciente primero
        turnos.sort((a, b) => b.fecha.compareTo(a.fecha));

        return {
          'success': true,
          'turnos': turnos,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener turnos',
        'turnos': <Turno>[],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en obtenerMisTurnos: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
        'turnos': <Turno>[],
      };
    }
  }

  // ============================================
  // CANCELAR TURNO
  // ============================================

  Future<Map<String, dynamic>> cancelarTurno(int turnoId) async {
    try {
      final response = await _apiService.put(
        ApiConfig.cancelarTurno(turnoId),
      );

      if (kDebugMode) {
        print('📅 Cancelar Turno Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
        };
      }

      return {
        'success': data['success'] ?? true,
        'message': data['message'] ?? 'Turno cancelado exitosamente',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en cancelarTurno: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }
}
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/slot_turno.dart';
import '../models/turno.dart';
import 'api_service.dart';

class TurnoService {
  final ApiService _apiService = ApiService();

  /// Obtiene los slots disponibles para una fecha específica
  /// Endpoint: GET /turnos/disponibles
  Future<Map<String, dynamic>> obtenerSlotsDisponibles(DateTime fecha) async {
    try {
      // Laravel espera la fecha en formato YYYY-MM-DD
      final String fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);

      final response = await _apiService.get(
        ApiConfig.turnosDisponibles,
        queryParameters: {
          'fecha': fechaFormateada,
        },
      );

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
          'slots': <SlotTurno>[],
        };
      }

      // Según tu controlador Laravel:
      // return response()->json(['success' => true, 'data' => ['slots' => [...]]])
      if (data['success'] == true) {
        final List<dynamic> slotsData = data['data']['slots'] ?? [];

        final List<SlotTurno> slots = slotsData
            .map((json) => SlotTurno.fromJson(json))
            .toList();

        return {
          'success': true,
          'slots': slots,
          'message': 'Slots cargados correctamente',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener disponibilidad',
        'slots': <SlotTurno>[],
      };

    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerSlotsDisponibles: $e');
      }
      // ApiService ya maneja las excepciones HTTP, pero capturamos errores de parseo
      return {
        'success': false,
        'message': e.toString(),
        'slots': <SlotTurno>[],
      };
    }
  }

  /// Realiza la reserva de un turno
  /// Endpoint: POST /turnos/reservar
  Future<Map<String, dynamic>> reservarTurno({
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    try {
      final String fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);

      final response = await _apiService.post(
        ApiConfig.reservarTurno,
        data: {
          'fecha': fechaFormateada,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
        },
      );

      final data = response.data;

      if (data['success'] == true) {

        final turno = Turno.fromJson(data['data']);

        return {
          'success': true,
          'turno': turno,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'No se pudo reservar el turno',
      };

    } catch (e) {
      if (kDebugMode) {
        print('Error en reservarTurno: $e');
      }
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
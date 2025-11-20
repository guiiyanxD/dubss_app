import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/slot_turno.dart';
import '../models/turno.dart';
import '../services/turno_service.dart';

class TurnoProvider extends ChangeNotifier {
  final TurnoService _turnoService = TurnoService();

  // Estado
  List<SlotTurno> _slotsDisponibles = [];
  DateTime _fechaSeleccionada = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SlotTurno> get slotsDisponibles => _slotsDisponibles;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga los slots disponibles para una fecha dada
  Future<void> cargarSlotsDisponibles(DateTime fecha) async {
    _fechaSeleccionada = fecha;
    _isLoading = true;
    _error = null;
    _slotsDisponibles = []; // Limpiamos la lista anterior visualmente
    notifyListeners();

    try {
      final result = await _turnoService.obtenerSlotsDisponibles(fecha);

      if (result['success'] == true) {
        _slotsDisponibles = result['slots'];
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Error inesperado al cargar turnos: $e';
      if (kDebugMode) {
        print('Error en cargarSlotsDisponibles: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Intenta reservar un turno
  /// Retorna el objeto Turno si es exitoso, o lanza una excepción si falla
  Future<Turno> reservarTurno({
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _turnoService.reservarTurno(
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );

      if (result['success'] == true) {
        // Reserva exitosa
        return result['turno'];
      } else {
        // Error de negocio (ej: turno ocupado o ya tienes reserva)
        final mensaje = result['message'] ?? 'Error al reservar';
        _error = mensaje;
        throw Exception(mensaje);
      }
    } catch (e) {
      // Propagamos el error para que la UI muestre el SnackBar
      if (_error == null) _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método helper para limpiar errores manualmente si la UI lo requiere
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
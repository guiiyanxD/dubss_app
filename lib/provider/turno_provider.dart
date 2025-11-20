// providers/turno_provider.dart

import 'package:flutter/foundation.dart';
import '../models/turno.dart';
import '../models/slot_turno.dart';
import '../services/turno_service.dart';

class TurnoProvider extends ChangeNotifier {
  final TurnoService _turnoService = TurnoService();

  // Estado
  List<Turno> _misTurnos = [];
  List<SlotDisponible> _slotsDisponibles = [];
  DateTime _fechaSeleccionada = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  String? _errorMessage;

  // Getters
  List<Turno> get misTurnos => _misTurnos;
  List<SlotDisponible> get slotsDisponibles => _slotsDisponibles;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  bool get isLoading => _isLoading;
  bool get isLoadingSlots => _isLoadingSlots;
  String? get errorMessage => _errorMessage;

  // Turnos filtrados
  List<Turno> get turnosProximos =>
      _misTurnos.where((t) => t.esProximo).toList();

  List<Turno> get turnosReservados =>
      _misTurnos.where((t) => t.esReservado).toList();

  List<Turno> get turnosAtendidos =>
      _misTurnos.where((t) => t.esAtendido).toList();

  List<Turno> get turnosCancelados =>
      _misTurnos.where((t) => t.esCancelado).toList();

  // Slots filtrados
  List<SlotDisponible> get slotsLibres =>
      _slotsDisponibles.where((s) => s.disponible).toList();

  List<SlotDisponible> get slotsOcupados =>
      _slotsDisponibles.where((s) => !s.disponible).toList();

  bool get haySlotsDisponibles => slotsLibres.isNotEmpty;

  // ============================================
  // CARGAR MIS TURNOS
  // ============================================

  Future<void> cargarMisTurnos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _turnoService.obtenerMisTurnos();

      if (result['success'] == true) {
        _misTurnos = result['turnos'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar turnos: $e';
      if (kDebugMode) {
        print('❌ Error en cargarMisTurnos: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // CARGAR SLOTS DISPONIBLES
  // ============================================

  Future<void> cargarSlotsDisponibles(DateTime fecha) async {
    _isLoadingSlots = true;
    _fechaSeleccionada = fecha;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _turnoService.obtenerTurnosDisponibles(
        fecha: fecha,
      );

      if (result['success'] == true) {
        _slotsDisponibles = result['slots'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
        _slotsDisponibles = [];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar horarios: $e';
      _slotsDisponibles = [];
      if (kDebugMode) {
        print('❌ Error en cargarSlotsDisponibles: $e');
      }
    } finally {
      _isLoadingSlots = false;
      notifyListeners();
    }
  }

  // ============================================
  // RESERVAR TURNO
  // ============================================

  Future<bool> reservarTurno({
    required String horaInicio,
    required String horaFin,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _turnoService.reservarTurno(
        fecha: _fechaSeleccionada,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );

      if (result['success'] == true) {
        // Recargar turnos y slots
        await cargarMisTurnos();
        await cargarSlotsDisponibles(_fechaSeleccionada);
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al reservar turno: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // CANCELAR TURNO
  // ============================================

  Future<bool> cancelarTurno(int turnoId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _turnoService.cancelarTurno(turnoId);

      if (result['success'] == true) {
        // Recargar turnos
        await cargarMisTurnos();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al cancelar turno: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SELECCIONAR FECHA
  // ============================================

  void seleccionarFecha(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
    cargarSlotsDisponibles(fecha);
  }

  // ============================================
  // LIMPIEZA
  // ============================================

  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
import 'package:flutter/foundation.dart';
import '../models/convocatoria.dart';
import '../services/convocatoria_service.dart';

class ConvocatoriaProvider extends ChangeNotifier {
  final ConvocatoriaService _convocatoriaService = ConvocatoriaService();


  List<Convocatoria> _convocatorias = [];
  Convocatoria? _convocatoriaSeleccionada;
  bool _isLoading = false;
  String? _errorMessage;
  String? _filtroTipoBeca;
  bool _soloActivas = true;

  // Getters
  List<Convocatoria> get convocatorias => _convocatorias;
  Convocatoria? get convocatoriaSeleccionada => _convocatoriaSeleccionada;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filtroTipoBeca => _filtroTipoBeca;
  bool get soloActivas => _soloActivas;

  // Convocatorias filtradas
  List<Convocatoria> get convocatoriasVigentes =>
      _convocatorias.where((c) => c.estaVigente).toList();

  List<Convocatoria> get convocatoriasProximas =>
      _convocatorias.where((c) => c.proximamente).toList();

  List<Convocatoria> get convocatoriasFinalizadas =>
      _convocatorias.where((c) => c.finalizada).toList();


  /**
   * get all cconvocatorias
   */
  Future<void> cargarConvocatorias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _convocatoriaService.obtenerConvocatorias(
        soloActivas: _soloActivas,
        tipoBeca: _filtroTipoBeca,
      );

      if (result['success'] == true) {
        _convocatorias = result['convocatorias'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Error al cargar convocatorias: $e';
      if (kDebugMode) {
        print('Error en cargar las Convocatorias: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * get convocatoria by id
   */
  Future<bool> cargarConvocatoria(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _convocatoriaService.obtenerConvocatoria(id);

      if (result['success'] == true) {
        _convocatoriaSeleccionada = result['convocatoria'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar convocatoria: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /**
   * filter by tipo
   */
  void setFiltroTipoBeca(String? tipo) {
    _filtroTipoBeca = tipo;
    notifyListeners();
    cargarConvocatorias();
  }

  /**
   * filter by available
   */
  void setSoloActivas(bool valor) {
    _soloActivas = valor;
    notifyListeners();
    cargarConvocatorias();
  }

  /**
   * clear all filters
   */
  void limpiarFiltros() {
    _filtroTipoBeca = null;
    _soloActivas = true;
    notifyListeners();
    cargarConvocatorias();
  }


  void seleccionarConvocatoria(Convocatoria convocatoria) {
    _convocatoriaSeleccionada = convocatoria;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _convocatoriaSeleccionada = null;
    notifyListeners();
  }


  List<Convocatoria> buscar(String query) {
    if (query.isEmpty) return _convocatorias;

    final queryLower = query.toLowerCase();
    return _convocatorias.where((conv) {
      return conv.nombre.toLowerCase().contains(queryLower) ||
          conv.codigo.toLowerCase().contains(queryLower) ||
          conv.subtipo.toLowerCase().contains(queryLower);
    }).toList();
  }


  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
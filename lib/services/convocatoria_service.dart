import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/convocatoria.dart';
import 'api_service.dart';

class ConvocatoriaService {
  final ApiService _apiService = ApiService();

  /**
   * Listta de todas las convocatorias
   */
  Future<Map<String, dynamic>> obtenerConvocatorias({
    bool? soloActivas,
    String? tipoBeca,
  }) async
  {
    try {

      final Map<String, dynamic> queryParams = {};

      if (soloActivas != null) {
        queryParams['activas'] = soloActivas ? '1' : '0';
      }

      if (tipoBeca != null && tipoBeca.isNotEmpty) {
        queryParams['tipo_beca'] = tipoBeca;
      }

      final response = await _apiService.get(
        ApiConfig.convocatorias,
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
          'convocatorias': <Convocatoria>[],
        };
      }

      if (data['success'] == true) {
        final List<dynamic> convocatoriasData = data['data'] ?? [];

        final List<Convocatoria> convocatorias = convocatoriasData
            .map((json) => Convocatoria.fromJson(json))
            .toList();

        return {
          'success': true,
          'convocatorias': convocatorias,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener convocatorias',
        'convocatorias': <Convocatoria>[],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en obtenerConvocatorias: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
        'convocatorias': <Convocatoria>[],
      };
    }
  }


  /**
   * Get convocatorias by ID
   */
  Future<Map<String, dynamic>> obtenerConvocatoria(int id) async {
    try {
      final response = await _apiService.get(
        ApiConfig.convocatoriaDetalle(id),
      );

      if (kDebugMode) {
        print('📋 Convocatoria Detail Response: ${response.data}');
      }

      final data = response.data;

      if (data == null) {
        return {
          'success': false,
          'message': 'Respuesta vacía del servidor',
        };
      }

      if (data['success'] == true) {
        final convocatoriaData = data['data'];

        return {
          'success': true,
          'convocatoria': Convocatoria.fromJson(convocatoriaData),
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Error al obtener convocatoria',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en obtenerConvocatoria: $e');
      }
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }


  /**
   * Get available convocatorias
   */
  Future<Map<String, dynamic>> obtenerConvocatoriasVigentes() async {
    final result = await obtenerConvocatorias(soloActivas: true);

    if (result['success'] == true) {
      final List<Convocatoria> todasConvocatorias = result['convocatorias'];

      // Filtrar solo las vigentes (no las próximas ni finalizadas)
      final List<Convocatoria> vigentes = todasConvocatorias
          .where((conv) => conv.estaVigente)
          .toList();

      return {
        'success': true,
        'convocatorias': vigentes,
        'message': 'Convocatorias vigentes obtenidas',
      };
    }

    return result;
  }
}
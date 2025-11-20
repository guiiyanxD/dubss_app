import 'package:dubss_android_app/models/requisito.dart';

class Convocatoria {
  final int id;
  final String nombre;
  final String codigo;
  final String tipoBeca;
  final String subtipo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime fechaLimiteApelacion;
  final double? diasRestantesApi;
  final bool activa;
  final String version;
  final List<Requisito> requisitos;

  Convocatoria({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipoBeca,
    required this.subtipo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaLimiteApelacion,
    this.diasRestantesApi,
    required this.activa,
    required this.version,
    this.requisitos = const [],
  });


  factory Convocatoria.fromJson(Map<String, dynamic> json) {
    List<Requisito> requisitos = [];
    if (json['requisitos'] != null) {
      requisitos = (json['requisitos'] as List)
          .map((req) => Requisito.fromJson(req))
          .toList();
      requisitos.sort((a, b) => a.orden.compareTo(b.orden));
    }
    return Convocatoria(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      tipoBeca: json['tipo_beca'] as String,
      subtipo: json['subtipo'] as String,
      descripcion: json['descripcion'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      fechaLimiteApelacion: DateTime.parse(json['fecha_limite_apelacion']),
      activa: json['activa'] == 1 || json['activa'] == true,
      diasRestantesApi: json['dias_restantes'] as double?,
      version: json['version'] as String? ?? '1.0.0',
      requisitos: requisitos,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'tipo_beca': tipoBeca,
      'subtipo': subtipo,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'fecha_limite_apelacion': fechaLimiteApelacion.toIso8601String(),
      'activa': activa,
      'version': version,
      'dias_restantes': diasRestantesApi,
      'requisitos': requisitos.map((req) => req.toJson()).toList(),
    };
  }


  bool get estaVigente {
    final now = DateTime.now();
    return activa &&
        now.isAfter(fechaInicio) &&
        now.isBefore(fechaFin);
  }

  bool get proximamente {
    return activa && DateTime.now().isBefore(fechaInicio);
  }

  bool get finalizada {
    return DateTime.now().isAfter(fechaFin);
  }

  String get estado {
    if (!activa) return 'Inactiva';
    if (proximamente) return 'Próximamente';
    if (estaVigente) return 'Vigente';
    if (finalizada) return 'Finalizada';
    return 'Desconocido';
  }

  int get diasRestantes {
    if (finalizada) return 0;
    return fechaFin.difference(DateTime.now()).inDays;
  }

  Convocatoria copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? tipoBeca,
    String? subtipo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? fechaLimiteApelacion,
    bool? activa,
    String? version,
    double? diasRestantesApi,
    List<Requisito>? requisitos,

  }) {
    return Convocatoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      tipoBeca: tipoBeca ?? this.tipoBeca,
      subtipo: subtipo ?? this.subtipo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaLimiteApelacion: fechaLimiteApelacion ?? this.fechaLimiteApelacion,
      activa: activa ?? this.activa,
      version: version ?? this.version,
      diasRestantesApi: diasRestantesApi ?? this.diasRestantesApi,
      requisitos: requisitos ?? this.requisitos,
    );
  }

  @override
  String toString() {
    return 'Convocatoria(id: $id, nombre: $nombre, codigo: $codigo, estado: $estado, requisitos: ${requisitos.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Convocatoria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
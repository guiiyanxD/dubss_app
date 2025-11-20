class Turno {
  final int id;
  final int usuarioId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String codigo;
  final String estado;
  final int duracionMinutos;
  final int? atendidoPor;
  final DateTime? atendidoEn;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Turno({
    required this.id,
    required this.usuarioId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.codigo,
    required this.estado,
    required this.duracionMinutos,
    this.atendidoPor,
    this.atendidoEn,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      fecha: DateTime.parse(json['fecha']),
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      codigo: json['codigo'] as String,
      estado: json['estado'] as String,
      duracionMinutos: json['duracion_minutos'] as int,
      atendidoPor: json['atendido_por'] as int?,
      atendidoEn: json['atendido_en'] != null
          ? DateTime.parse(json['atendido_en'])
          : null,
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'codigo': codigo,
      'estado': estado,
      'duracion_minutos': duracionMinutos,
      'atendido_por': atendidoPor,
      'atendido_en': atendidoEn?.toIso8601String(),
      'observaciones': observaciones,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters útiles
  bool get estaReservado => estado == 'reservado';
  bool get estaAtendido => estado == 'atendido';
  bool get estaCancelado => estado == 'cancelado';
  bool get estaVencido => estado == 'vencido';

  DateTime get fechaHoraInicio {
    final parts = horaInicio.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime get fechaHoraFin {
    final parts = horaFin.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool get yaVencio {
    return DateTime.now().isAfter(fechaHoraFin);
  }

  bool get puedeSerCancelado {
    return estaReservado && DateTime.now().isBefore(fechaHoraInicio);
  }

  String get estadoTexto {
    switch (estado) {
      case 'reservado':
        return 'Reservado';
      case 'atendido':
        return 'Atendido';
      case 'cancelado':
        return 'Cancelado';
      case 'vencido':
        return 'Vencido';
      default:
        return 'Desconocido';
    }
  }

  Duration get tiempoRestante {
    if (yaVencio) return Duration.zero;
    return fechaHoraInicio.difference(DateTime.now());
  }

  String get rangoHorario => '$horaInicio - $horaFin';

  Turno copyWith({
    int? id,
    int? usuarioId,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    String? codigo,
    String? estado,
    int? duracionMinutos,
    int? atendidoPor,
    DateTime? atendidoEn,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Turno(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      codigo: codigo ?? this.codigo,
      estado: estado ?? this.estado,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      atendidoPor: atendidoPor ?? this.atendidoPor,
      atendidoEn: atendidoEn ?? this.atendidoEn,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Turno(codigo: $codigo, fecha: $fecha, hora: $rangoHorario, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Turno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
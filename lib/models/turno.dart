class Turno {
  final int id;
  final int usuarioId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String codigo;
  final String estado; // reservado, atendido, cancelado, vencido
  final int duracionMinutos;
  final int? atendidoPor;
  final DateTime? atendidoEn;
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
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      fecha: DateTime.parse(json['fecha']),
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      codigo: json['codigo'] as String,
      estado: json['estado'] as String,
      duracionMinutos: json['duracion_minutos'] as int? ?? 15,
      atendidoPor: json['atendido_por'] as int?,
      atendidoEn: json['atendido_en'] != null
          ? DateTime.parse(json['atendido_en'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // ============================================
  // TO JSON
  // ============================================

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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ============================================
  // GETTERS
  // ============================================

  bool get esReservado => estado == 'reservado';
  bool get esAtendido => estado == 'atendido';
  bool get esCancelado => estado == 'cancelado';
  bool get esVencido => estado == 'vencido';

  bool get puedeSerCancelado {
    if (!esReservado) return false;

    final ahora = DateTime.now();
    final fechaTurno = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(horaInicio.split(':')[0]),
      int.parse(horaInicio.split(':')[1]),
    );

    // Solo se puede cancelar si falta al menos 1 hora
    return fechaTurno.difference(ahora).inHours >= 1;
  }

  bool get esProximo {
    final ahora = DateTime.now();
    final fechaTurno = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(horaInicio.split(':')[0]),
      int.parse(horaInicio.split(':')[1]),
    );

    return esReservado && fechaTurno.isAfter(ahora);
  }

  String get horaCompletaTexto => '$horaInicio - $horaFin';

  DateTime get fechaHoraCompleta {
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(horaInicio.split(':')[0]),
      int.parse(horaInicio.split(':')[1]),
    );
  }

  // ============================================
  // COPY WITH
  // ============================================

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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // TO STRING
  // ============================================

  @override
  String toString() {
    return 'Turno(codigo: $codigo, fecha: $fecha, hora: $horaInicio, estado: $estado)';
  }

  // ============================================
  // EQUALITY
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Turno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

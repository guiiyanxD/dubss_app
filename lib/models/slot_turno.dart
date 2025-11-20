class SlotTurno {
  final String horaInicio;
  final String horaFin;
  final bool disponible;

  SlotTurno({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
  });

  factory SlotTurno.fromJson(Map<String, dynamic> json) {
    return SlotTurno(
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'disponible': disponible,
    };
  }

  String get rangoHorario => '$horaInicio - $horaFin';

  @override
  String toString() {
    return 'SlotTurno($rangoHorario, disponible: $disponible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlotTurno &&
        other.horaInicio == horaInicio &&
        other.horaFin == horaFin;
  }

  @override
  int get hashCode => horaInicio.hashCode ^ horaFin.hashCode;
}
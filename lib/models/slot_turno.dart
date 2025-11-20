class SlotDisponible {
  final String horaInicio;
  final String horaFin;
  final bool disponible;

  SlotDisponible({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
  });

  factory SlotDisponible.fromJson(Map<String, dynamic> json) {
    return SlotDisponible(
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
    return other is SlotDisponible &&
        other.horaInicio == horaInicio &&
        other.horaFin == horaFin;
  }
  String get horaTexto => '$horaInicio - $horaFin';
  @override
  int get hashCode => horaInicio.hashCode ^ horaFin.hashCode;
}
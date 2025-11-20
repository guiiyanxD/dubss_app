class Requisito {
  final int id;
  final String nombre;
  final String descripcion;
  final bool esObligatorio;
  final int orden;
  final String? instrucciones;
  final String tipoArchivo;
  final int tamanoMaxMb;

  Requisito({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.esObligatorio,
    required this.orden,
    this.instrucciones,
    required this.tipoArchivo,
    required this.tamanoMaxMb,
  });

  factory Requisito.fromJson(Map<String, dynamic> json) {
    return Requisito(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      esObligatorio: json['es_obligatorio'] == 1 || json['es_obligatorio'] == true,
      orden: json['orden'] as int,
      instrucciones: json['instrucciones'] as String?,
      tipoArchivo: json['tipo_archivo'] as String,
      tamanoMaxMb: json['tamano_max_mb'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'es_obligatorio': esObligatorio,
      'orden': orden,
      'instrucciones': instrucciones,
      'tipo_archivo': tipoArchivo,
      'tamano_max_mb': tamanoMaxMb,
    };
  }

  List<String> get tiposArchivoPermitidos {
    return tipoArchivo.split(',').map((e) => e.trim()).toList();
  }

  @override
  String toString() {
    return 'Requisito(id: $id, nombre: $nombre, obligatorio: $esObligatorio)';
  }
}
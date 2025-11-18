class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String ci;
  final String email;
  final String? telefono;
  final String rol;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.ci,
    required this.email,
    this.telefono,
    required this.rol,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      ci: json['ci'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
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
      'nombre': nombre,
      'apellido': apellido,
      'ci': ci,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ============================================
  // COPY WITH
  // ============================================

  Usuario copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? ci,
    String? email,
    String? telefono,
    String? rol,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      ci: ci ?? this.ci,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // GETTERS
  // ============================================

  String get nombreCompleto => '$nombre $apellido';

  bool get esEstudiante => rol == 'estudiante';
  bool get esOperador => rol == 'operador';
  bool get esAdmin => rol == 'admin';

  bool get emailVerificado => emailVerifiedAt != null;

  // ============================================
  // TO STRING
  // ============================================

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombreCompleto, email: $email, rol: $rol)';
  }

  // ============================================
  // EQUALITY
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
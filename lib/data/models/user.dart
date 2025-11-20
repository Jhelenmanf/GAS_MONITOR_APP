// ═══════════════════════════════════════════════════════════
// 👤 MODELO DE USUARIO
// ═══════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nombre;
  final String usuario;
  final String passwordHash;
  final int createdAt;
  final int? lastLogin;

  const User({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.passwordHash,
    required this.createdAt,
    this.lastLogin,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'password_hash': passwordHash,
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }

  // Crear desde Map de SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      usuario: map['usuario'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] as int,
      lastLogin: map['last_login'] as int?,
    );
  }

  // Copiar con modificaciones
  User copyWith({
    String? id,
    String? nombre,
    String? usuario,
    String? passwordHash,
    int? createdAt,
    int? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      usuario: usuario ?? this.usuario,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Usuario formateado con @
  String get usuarioFormateado => '@$usuario';

  @override
  List<Object?> get props => [id, nombre, usuario, passwordHash, createdAt, lastLogin];
}

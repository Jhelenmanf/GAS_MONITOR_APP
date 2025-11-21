// ═══════════════════════════════════════════════════════════
// 🔐 SERVICIO DE AUTENTICACIÓN
// ═══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user.dart';
import '../data/database/database_helper.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Hash de contraseña con SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Registrar nuevo usuario
  Future<User?> register({
    required String nombre,
    required String usuario,
    required String password,
  }) async {
    try {
      // Verificar si el usuario ya existe
      if (await _db.usernameExists(usuario)) {
        return null; // Usuario ya existe
      }

      // Crear nuevo usuario
      final newUser = User(
        id: _uuid.v4(),
        nombre: nombre,
        usuario: usuario,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      return await _db.createUser(newUser);
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<User?> login({
    required String usuario,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final user = await _db.getUserByUsername(usuario);
      if (user == null) return null;

      // Verificar contraseña
      final passwordHash = _hashPassword(password);
      if (user.passwordHash != passwordHash) return null;

      // Actualizar último login
      await _db.updateLastLogin(user.id);

      // Guardar sesión si "Recordarme" está activado
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString(AppConstants.keyLoggedInUser, user.id);
        await prefs.setBool(AppConstants.keyRememberMe, true);
      } else {
        await prefs.setString(AppConstants.keyLoggedInUser, user.id);
        await prefs.setBool(AppConstants.keyRememberMe, false);
      }

      return user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Obtener usuario logueado
  Future<User?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.keyLoggedInUser);
      
      if (userId == null) return null;
      
      return await _db.getUserById(userId);
    } catch (e) {
      print('Error obteniendo usuario logueado: $e');
      return null;
    }
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final user = await getLoggedInUser();
    return user != null;
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyLoggedInUser);
      await prefs.setBool(AppConstants.keyRememberMe, false);
    } catch (e) {
      print('Error en logout: $e');
    }
  }

  // Verificar si "Recordarme" está activado
  Future<bool> shouldRememberUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyRememberMe) ?? false;
  }
}

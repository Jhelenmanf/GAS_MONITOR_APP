// ═══════════════════════════════════════════════════════════
// ✅ VALIDADORES DE ENTRADA
// ═══════════════════════════════════════════════════════════

import '../constants/app_constants.dart';

class Validators {
  // Validar nombre completo
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }
  
  // Validar usuario (sin @)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El usuario es requerido';
    }
    if (value.contains('@')) {
      return 'El usuario no debe contener @';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'El usuario debe tener al menos ${AppConstants.minUsernameLength} caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Solo se permiten letras, números y guión bajo';
    }
    return null;
  }
  
  // Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    return null;
  }
  
  // Validar confirmación de contraseña
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}

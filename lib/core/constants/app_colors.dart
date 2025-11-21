// ═══════════════════════════════════════════════════════════
// 🎨 COLORES DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppColors {
  // Colores de estado según nivel de gas
  static const Color safe = Color(0xFF4CAF50);        // Verde - Seguro
  static const Color warning = Color(0xFFFFC107);     // Amarillo - Precaución
  static const Color danger = Color(0xFFF44336);      // Rojo - Peligro
  
  // Tema oscuro
  static const Color background = Color(0xFF121212);  // Negro
  static const Color cardBackground = Color(0xFF1E1E1E); // Gris oscuro
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  // Estados de conexión
  static const Color connected = Color(0xFF4CAF50);    // Verde
  static const Color disconnected = Color(0xFFF44336); // Rojo
}

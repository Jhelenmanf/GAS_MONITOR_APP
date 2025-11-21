// ═══════════════════════════════════════════════════════════
// 🚨 MODELO DE NIVEL DE ALARMA
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum AlarmLevel {
  safe,      // 0-21 PPM
  warning,   // 21-30 PPM
  danger     // >30 PPM
}

extension AlarmLevelExtension on AlarmLevel {
  // Obtener nivel según valor de PPM
  static AlarmLevel fromPPM(double ppm) {
    if (ppm >= AppConstants.thresholdDanger) {
      return AlarmLevel.danger;
    } else if (ppm >= AppConstants.thresholdWarning) {
      return AlarmLevel.warning;
    }
    return AlarmLevel.safe;
  }
  
  // Color según nivel
  Color get color {
    switch (this) {
      case AlarmLevel.safe:
        return AppColors.safe;
      case AlarmLevel.warning:
        return AppColors.warning;
      case AlarmLevel.danger:
        return AppColors.danger;
    }
  }
  
  // Texto descriptivo
  String get text {
    switch (this) {
      case AlarmLevel.safe:
        return 'Seguro';
      case AlarmLevel.warning:
        return 'Precaución';
      case AlarmLevel.danger:
        return 'Peligro';
    }
  }
  
  // Icono según nivel
  IconData get icon {
    switch (this) {
      case AlarmLevel.safe:
        return Icons.check_circle;
      case AlarmLevel.warning:
        return Icons.warning;
      case AlarmLevel.danger:
        return Icons.dangerous;
    }
  }
  
  // Valor numérico para base de datos
  int get value {
    switch (this) {
      case AlarmLevel.safe:
        return 0;
      case AlarmLevel.warning:
        return 1;
      case AlarmLevel.danger:
        return 2;
    }
  }
  
  // Obtener nivel desde valor numérico
  static AlarmLevel fromValue(int value) {
    switch (value) {
      case 0:
        return AlarmLevel.safe;
      case 1:
        return AlarmLevel.warning;
      case 2:
        return AlarmLevel.danger;
      default:
        return AlarmLevel.safe;
    }
  }
}

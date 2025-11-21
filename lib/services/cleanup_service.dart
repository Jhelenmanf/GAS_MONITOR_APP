// ═══════════════════════════════════════════════════════════
// 🧹 SERVICIO DE LIMPIEZA AUTOMÁTICA
// ═══════════════════════════════════════════════════════════

import '../data/database/database_helper.dart';
import '../core/constants/app_constants.dart';

class CleanupService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Limpiar datos antiguos de un usuario (>10 horas)
  Future<int> cleanOldData(String usuarioId) async {
    try {
      final deletedCount = await _db.cleanOldReadings(
        usuarioId,
        hours: AppConstants.dataRetentionHours,
      );
      
      if (deletedCount > 0) {
        print('🧹 Limpieza automática: $deletedCount lecturas eliminadas');
      }
      
      return deletedCount;
    } catch (e) {
      print('❌ Error en limpieza automática: $e');
      return 0;
    }
  }

  // Limpiar todo el historial de un usuario
  Future<bool> clearAllHistory(String usuarioId) async {
    try {
      await _db.deleteAllUserReadings(usuarioId);
      print('🗑️ Todo el historial del usuario eliminado');
      return true;
    } catch (e) {
      print('❌ Error limpiando historial: $e');
      return false;
    }
  }

  // Obtener tamaño aproximado del historial en MB
  Future<double> getHistorySizeInMB(String usuarioId) async {
    try {
      final count = await _db.countUserReadings(usuarioId);
      // Estimación: cada lectura ocupa aproximadamente 0.5 KB
      final sizeInKB = count * 0.5;
      final sizeInMB = sizeInKB / 1024;
      return sizeInMB;
    } catch (e) {
      print('❌ Error calculando tamaño: $e');
      return 0.0;
    }
  }
}

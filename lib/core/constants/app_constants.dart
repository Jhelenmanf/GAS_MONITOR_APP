// ═══════════════════════════════════════════════════════════
// 📋 CONSTANTES DE LA APLICACIÓN
// ═══════════════════════════════════════════════════════════

class AppConstants {
  // Versión de la aplicación
  static const String appVersion = '1.0.0';
  static const String appName = 'DetGas Monitor';
  
  // Umbrales de alarma (PPM)
  static const double thresholdWarning = 21.0;  // Precaución
  static const double thresholdDanger = 30.0;   // Peligro
  
  // Política de retención de datos
  static const int dataRetentionHours = 10; // Guardar últimas 10 horas
  
  // Intervalos de actualización
  static const int sensorUpdateInterval = 10; // segundos
  static const int connectionCheckInterval = 30; // segundos
  
  // Validaciones de usuario
  static const int minUsernameLength = 4;
  static const int minPasswordLength = 6;
  
  // Base de datos
  static const String databaseName = 'detgas.db';
  static const int databaseVersion = 1;
  
  // SharedPreferences keys
  static const String keyLoggedInUser = 'logged_in_user';
  static const String keyRememberMe = 'remember_me';
  static const String keyAutoCloseValve = 'auto_close_valve';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
}

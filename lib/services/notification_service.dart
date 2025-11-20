// ═══════════════════════════════════════════════════════════
// 🔔 SERVICIO DE NOTIFICACIONES
// ═══════════════════════════════════════════════════════════

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/alarm_level.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Inicializar servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Servicio de notificaciones inicializado');
  }

  // Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica si lo necesitas
  }

  // Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  // Verificar si el sonido está habilitado
  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keySoundEnabled) ?? true;
  }

  // Verificar si la vibración está habilitada
  Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyVibrationEnabled) ?? true;
  }

  // Mostrar notificación de precaución (21-30 PPM)
  Future<void> showWarningNotification(double ppm) async {
    if (!await areNotificationsEnabled()) return;

    final soundEnabled = await isSoundEnabled();
    final vibrationEnabled = await isVibrationEnabled();

    final androidDetails = AndroidNotificationDetails(
      'gas_warning',
      'Advertencias de Gas',
      channelDescription: 'Notificaciones de niveles de gas en precaución',
      importance: Importance.high,
      priority: Priority.high,
      playSound: soundEnabled,
      sound: soundEnabled ? const RawResourceAndroidNotificationSound('warning_sound') : null,
      enableVibration: vibrationEnabled,
      vibrationPattern: vibrationEnabled ? Int64List.fromList([0, 500, 200, 500]) : null,
      color: const Color(0xFFFFC107),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'warning_sound.aiff',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '⚠️ Precaución: Gas Detectado',
      'Nivel de gas: ${ppm.toStringAsFixed(1)} PPM',
      details,
      payload: 'warning',
    );

    print('📣 Notificación de precaución enviada');
  }

  // Mostrar notificación de peligro (>30 PPM)
  Future<void> showDangerNotification(double ppm, {bool valveClosed = false}) async {
    if (!await areNotificationsEnabled()) return;

    final soundEnabled = await isSoundEnabled();
    final vibrationEnabled = await isVibrationEnabled();

    final message = valveClosed
        ? 'Nivel: ${ppm.toStringAsFixed(1)} PPM - Válvula cerrada automáticamente'
        : 'Nivel: ${ppm.toStringAsFixed(1)} PPM - ¡Evacúe el área!';

    final androidDetails = AndroidNotificationDetails(
      'gas_danger',
      'Alertas Críticas de Gas',
      channelDescription: 'Notificaciones de niveles peligrosos de gas',
      importance: Importance.max,
      priority: Priority.max,
      playSound: soundEnabled,
      sound: soundEnabled ? const RawResourceAndroidNotificationSound('alarm_sound') : null,
      enableVibration: vibrationEnabled,
      vibrationPattern: vibrationEnabled 
          ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000]) 
          : null,
      color: const Color(0xFFF44336),
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '🚨 ¡PELIGRO! Gas Crítico',
      message,
      details,
      payload: 'danger',
    );

    print('🚨 Notificación de peligro enviada');
  }

  // Mostrar notificación de desconexión
  Future<void> showDisconnectionNotification() async {
    if (!await areNotificationsEnabled()) return;

    const androidDetails = AndroidNotificationDetails(
      'system_alerts',
      'Alertas del Sistema',
      channelDescription: 'Notificaciones de estado del sistema',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFF44336),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      '⚠️ Sistema Desconectado',
      'Sin comunicación con el sensor hace >30 segundos',
      details,
      payload: 'disconnection',
    );

    print('📡 Notificación de desconexión enviada');
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancelar notificación específica
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

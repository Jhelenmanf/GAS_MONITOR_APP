// ═══════════════════════════════════════════════════════════
// 📡 CONFIGURACIÓN MQTT - Credenciales HiveMQ Cloud
// ═══════════════════════════════════════════════════════════

class MqttConfig {
  // Información del broker HiveMQ Cloud
  static const String broker = '8d1f3016a8dd40d5b0565c2cce462b15.s1.eu.hivemq.cloud';
  static const int port = 8883; // Puerto TLS/SSL
  static const String username = 'detgas';
  static const String password = 'Figueroa2003.';
  
  // Topics MQTT
  static const String topicSensorData = 'gas/sensor/data';      // Recibe datos del sensor
  static const String topicValveStatus = 'gas/valve/status';    // Recibe estado de válvula
  static const String topicValveControl = 'gas/valve/control';  // Envía comandos de control
  
  // Configuración de reconexión
  static const int reconnectDelay = 5; // segundos
  static const int keepAlivePeriod = 20; // segundos
}

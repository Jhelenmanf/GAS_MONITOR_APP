// ═══════════════════════════════════════════════════════════
// 📡 SERVICIO MQTT - Conexión con HiveMQ Cloud
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/constants/mqtt_config.dart';
import '../data/models/gas_reading.dart';

class MQTTService {
  // Cliente MQTT
  late MqttServerClient client;
  
  // Streams para comunicación
  final _readingsController = StreamController<GasReading>.broadcast();
  final _valveStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<GasReading> get readingsStream => _readingsController.stream;
  Stream<Map<String, dynamic>> get valveStatusStream => _valveStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _currentUserId;

  // Conectar al broker HiveMQ Cloud
  Future<bool> connect(String userId) async {
    try {
      _currentUserId = userId;
      
      // Crear cliente con ID único
      final clientId = 'flutter_app_${DateTime.now().millisecondsSinceEpoch}';
      client = MqttServerClient.withPort(
        MqttConfig.broker,
        clientId,
        MqttConfig.port,
      );

      // Configuración del cliente
      client.logging(on: false);
      client.keepAlivePeriod = MqttConfig.keepAlivePeriod;
      client.autoReconnect = true;
      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;
      client.onAutoReconnect = _onAutoReconnect;
      client.onAutoReconnected = _onAutoReconnected;
      
      // Configurar contexto de seguridad TLS/SSL
      final securityContext = SecurityContext.defaultContext;
      client.securityContext = securityContext;
      client.secure = true;

      // Mensaje de conexión
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(MqttConfig.username, MqttConfig.password)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client.connectionMessage = connMessage;

      // Intentar conexión
      print('🔄 Conectando a HiveMQ Cloud...');
      await client.connect();

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ Conectado a HiveMQ Cloud');
        _isConnected = true;
        _connectionController.add(true);
        
        // Suscribirse a topics
        _subscribeToTopics();
        
        return true;
      } else {
        print('❌ Error en conexión: ${client.connectionStatus?.state}');
        _isConnected = false;
        _connectionController.add(false);
        return false;
      }
    } catch (e) {
      print('❌ Excepción al conectar: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  // Suscribirse a topics
  void _subscribeToTopics() {
    // Suscribirse a datos del sensor
    client.subscribe(MqttConfig.topicSensorData, MqttQos.atLeastOnce);
    
    // Suscribirse a estado de válvula
    client.subscribe(MqttConfig.topicValveStatus, MqttQos.atLeastOnce);

    // Escuchar mensajes
    client.updates?.listen(_handleMessage);
    
    print('📡 Suscrito a topics MQTT');
  }

  // Manejar mensajes recibidos
  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = message.payload as MqttPublishMessage;
      final payloadString = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      try {
        final json = jsonDecode(payloadString) as Map<String, dynamic>;

        // Procesar según el topic
        if (topic == MqttConfig.topicSensorData) {
          _handleSensorData(json);
        } else if (topic == MqttConfig.topicValveStatus) {
          _handleValveStatus(json);
        }
      } catch (e) {
        print('❌ Error procesando mensaje de $topic: $e');
      }
    }
  }

  // Procesar datos del sensor
  void _handleSensorData(Map<String, dynamic> json) {
    if (_currentUserId == null) return;
    
    try {
      final reading = GasReading.fromMqttJson(json, _currentUserId!);
      _readingsController.add(reading);
      print('📊 Nueva lectura: ${reading.ppm} PPM');
    } catch (e) {
      print('❌ Error procesando datos del sensor: $e');
    }
  }

  // Procesar estado de válvula
  void _handleValveStatus(Map<String, dynamic> json) {
    _valveStatusController.add(json);
    print('🎛️ Estado de válvula: ${json['estado']}');
  }

  // Enviar comando de control de válvula
  Future<void> closeValve() async {
    if (!_isConnected) {
      print('❌ No conectado a MQTT');
      return;
    }

    try {
      final message = jsonEncode({'action': 'CLOSE'});
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      
      client.publishMessage(
        MqttConfig.topicValveControl,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      
      print('🔒 Comando de cierre enviado');
    } catch (e) {
      print('❌ Error enviando comando: $e');
    }
  }

  // Callbacks de conexión
  void _onConnected() {
    print('✅ Callback: Conectado');
    _isConnected = true;
    _connectionController.add(true);
  }

  void _onDisconnected() {
    print('⚠️ Callback: Desconectado');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _onAutoReconnect() {
    print('🔄 Callback: Reintentando conexión...');
  }

  void _onAutoReconnected() {
    print('✅ Callback: Reconectado automáticamente');
    _isConnected = true;
    _connectionController.add(true);
    _subscribeToTopics();
  }

  // Desconectar
  void disconnect() {
    if (_isConnected) {
      client.disconnect();
      _isConnected = false;
      _connectionController.add(false);
      print('🔌 Desconectado de HiveMQ Cloud');
    }
  }

  // Limpiar recursos
  void dispose() {
    disconnect();
    _readingsController.close();
    _valveStatusController.close();
    _connectionController.close();
  }
}

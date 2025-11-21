// ═══════════════════════════════════════════════════════════
// 📊 MODELO DE LECTURA DE GAS
// ═══════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'alarm_level.dart';

class GasReading extends Equatable {
  final String id;
  final int timestamp;
  final double ppm;
  final int valorSensor;
  final bool gasDetectado;
  final AlarmLevel nivelAlarma;
  final String? accionTomada;
  final String usuarioId;

  const GasReading({
    required this.id,
    required this.timestamp,
    required this.ppm,
    required this.valorSensor,
    required this.gasDetectado,
    required this.nivelAlarma,
    this.accionTomada,
    required this.usuarioId,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'ppm': ppm,
      'valor_sensor': valorSensor,
      'gas_detectado': gasDetectado ? 1 : 0,
      'nivel_alarma': nivelAlarma.value,
      'accion_tomada': accionTomada,
      'usuario_id': usuarioId,
    };
  }

  // Crear desde Map de SQLite
  factory GasReading.fromMap(Map<String, dynamic> map) {
    return GasReading(
      id: map['id'] as String,
      timestamp: map['timestamp'] as int,
      ppm: map['ppm'] as double,
      valorSensor: map['valor_sensor'] as int,
      gasDetectado: map['gas_detectado'] == 1,
      nivelAlarma: AlarmLevelExtension.fromValue(map['nivel_alarma'] as int),
      accionTomada: map['accion_tomada'] as String?,
      usuarioId: map['usuario_id'] as String,
    );
  }

  // Crear desde JSON recibido por MQTT
  factory GasReading.fromMqttJson(Map<String, dynamic> json, String usuarioId, {String? accion}) {
    final ppm = (json['ppm'] as num).toDouble();
    return GasReading(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] as int,
      ppm: ppm,
      valorSensor: json['valorSensor'] as int,
      gasDetectado: json['gasDetectado'] as bool,
      nivelAlarma: AlarmLevelExtension.fromPPM(ppm),
      accionTomada: accion,
      usuarioId: usuarioId,
    );
  }

  // Copiar con modificaciones
  GasReading copyWith({
    String? id,
    int? timestamp,
    double? ppm,
    int? valorSensor,
    bool? gasDetectado,
    AlarmLevel? nivelAlarma,
    String? accionTomada,
    String? usuarioId,
  }) {
    return GasReading(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      ppm: ppm ?? this.ppm,
      valorSensor: valorSensor ?? this.valorSensor,
      gasDetectado: gasDetectado ?? this.gasDetectado,
      nivelAlarma: nivelAlarma ?? this.nivelAlarma,
      accionTomada: accionTomada ?? this.accionTomada,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  // Obtener DateTime desde timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  @override
  List<Object?> get props => [
        id,
        timestamp,
        ppm,
        valorSensor,
        gasDetectado,
        nivelAlarma,
        accionTomada,
        usuarioId,
      ];
}

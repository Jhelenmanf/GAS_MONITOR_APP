// ═══════════════════════════════════════════════════════════
// 🧪 PRUEBAS BÁSICAS DE WIDGETS
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gas_monitor_app/main.dart';

void main() {
  testWidgets('Splash screen se muestra correctamente', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const MyApp());

    // Verificar que el splash screen se muestra
    expect(find.text('DetGas Monitor'), findsOneWidget);
    expect(find.text('Sistema de Detección de Gas IoT'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Icono de fuego se muestra en splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verificar que el icono de fuego está presente
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });
}

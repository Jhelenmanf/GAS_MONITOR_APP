// ═══════════════════════════════════════════════════════════
// 📊 WIDGET DE GAUGE DE GAS
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../data/models/gas_reading.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class GasGauge extends StatelessWidget {
  final GasReading reading;

  const GasGauge({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Gauge circular
            SizedBox(
              height: 250,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: AppConstants.thresholdWarning,
                        color: AppColors.safe,
                        startWidth: 20,
                        endWidth: 20,
                      ),
                      GaugeRange(
                        startValue: AppConstants.thresholdWarning,
                        endValue: AppConstants.thresholdDanger,
                        color: AppColors.warning,
                        startWidth: 20,
                        endWidth: 20,
                      ),
                      GaugeRange(
                        startValue: AppConstants.thresholdDanger,
                        endValue: 100,
                        color: AppColors.danger,
                        startWidth: 20,
                        endWidth: 20,
                      ),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: reading.ppm > 100 ? 100 : reading.ppm,
                        needleColor: reading.nivelAlarma.color,
                        needleLength: 0.7,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        knobStyle: KnobStyle(
                          color: reading.nivelAlarma.color,
                          borderColor: Colors.white,
                          borderWidth: 0.05,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reading.ppm.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: reading.nivelAlarma.color,
                              ),
                            ),
                            Text(
                              'PPM',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.2,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    showTicks: false,
                    showLabels: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Estado textual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: reading.nivelAlarma.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reading.nivelAlarma.icon,
                    color: reading.nivelAlarma.color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reading.nivelAlarma.text.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: reading.nivelAlarma.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Información adicional
            Text(
              'Valor del sensor: ${reading.valorSensor}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

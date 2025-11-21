// ═══════════════════════════════════════════════════════════
// 📈 WIDGET DE GRÁFICO DE LECTURAS
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/gas_reading.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ChartWidget extends StatelessWidget {
  final List<GasReading> readings;

  const ChartWidget({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay datos para mostrar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Ordenar lecturas por timestamp ascendente
    final sortedReadings = List<GasReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Crear puntos del gráfico
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedReadings.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedReadings[i].ppm));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondary.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: sortedReadings.length > 10 
                    ? (sortedReadings.length / 5).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedReadings.length) {
                    return const SizedBox.shrink();
                  }
                  final reading = sortedReadings[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm').format(reading.dateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
          ),
          minX: 0,
          maxX: (sortedReadings.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.safe,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  Color dotColor;
                  if (spot.y >= AppConstants.thresholdDanger) {
                    dotColor = AppColors.danger;
                  } else if (spot.y >= AppConstants.thresholdWarning) {
                    dotColor = AppColors.warning;
                  } else {
                    dotColor = AppColors.safe;
                  }
                  
                  return FlDotCirclePainter(
                    radius: 4,
                    color: dotColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.safe.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.cardBackground,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < sortedReadings.length) {
                    final reading = sortedReadings[index];
                    return LineTooltipItem(
                      '${reading.ppm.toStringAsFixed(1)} PPM\n${DateFormat('HH:mm:ss').format(reading.dateTime)}',
                      GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

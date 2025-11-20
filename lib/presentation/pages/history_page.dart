// ═══════════════════════════════════════════════════════════
// 🕒 PÁGINA DE HISTORIAL
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/cleanup_service.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/gas_reading.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/chart_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AuthService _authService = AuthService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final CleanupService _cleanupService = CleanupService();
  
  List<GasReading> _readings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() => _isLoading = true);

    final user = await _authService.getLoggedInUser();
    if (user == null) return;

    // Limpiar datos antiguos automáticamente
    await _cleanupService.cleanOldData(user.id);

    // Cargar lecturas
    final readings = await _db.getUserReadings(user.id, hours: 10);
    
    setState(() {
      _readings = readings;
      _isLoading = false;
    });
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '🗑️ Borrar Historial',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro que deseas borrar todo tu historial?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = await _authService.getLoggedInUser();
      if (user == null) return;

      final success = await _cleanupService.clearAllHistory(user.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial eliminado'),
            backgroundColor: AppColors.safe,
          ),
        );
        await _loadReadings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadReadings,
      color: AppColors.safe,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.safe))
          : _readings.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gráfico
                      Card(
                        color: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Últimas 10 Horas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                    onPressed: _clearAllHistory,
                                    tooltip: 'Borrar todo',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ChartWidget(readings: _readings),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lista de eventos
                      Text(
                        'Eventos Recientes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _readings.length > 50 ? 50 : _readings.length,
                        itemBuilder: (context, index) {
                          final reading = _readings[index];
                          return _buildReadingCard(reading);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay historial disponible',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las lecturas aparecerán aquí',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(GasReading reading) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reading.nivelAlarma.color.withOpacity(0.2),
          child: Icon(
            reading.nivelAlarma.icon,
            color: reading.nivelAlarma.color,
          ),
        ),
        title: Row(
          children: [
            Text(
              '${reading.ppm.toStringAsFixed(1)} PPM',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: reading.nivelAlarma.color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: reading.nivelAlarma.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reading.nivelAlarma.text,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: reading.nivelAlarma.color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd/MM/yyyy HH:mm:ss').format(reading.dateTime),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (reading.accionTomada != null)
              Text(
                reading.accionTomada!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.danger,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

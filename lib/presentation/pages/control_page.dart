// ═══════════════════════════════════════════════════════════
// 🎛️ PÁGINA DE CONTROL DE VÁLVULA
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/mqtt_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final MQTTService _mqttService = MQTTService();
  
  bool _isValveOpen = true; // Por defecto abierta
  bool _autoClose = true; // Cierre automático activado por defecto
  StreamSubscription? _valveStatusSubscription;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _subscribeToValveStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoClose = prefs.getBool(AppConstants.keyAutoCloseValve) ?? true;
    });
  }

  void _subscribeToValveStatus() {
    _valveStatusSubscription = _mqttService.valveStatusStream.listen((status) {
      final estado = status['estado'] as String?;
      setState(() {
        _isValveOpen = estado != 'cerrada';
      });
    });
  }

  Future<void> _toggleAutoClose(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAutoCloseValve, value);
    setState(() {
      _autoClose = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value 
              ? 'Cierre automático activado'
              : 'Cierre automático desactivado',
        ),
        backgroundColor: AppColors.safe,
      ),
    );
  }

  Future<void> _closeValve() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '🔒 Cerrar Válvula',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar la válvula de gas?\n\nLa válvula debe abrirse manualmente después de verificar la seguridad.',
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
            child: const Text('Cerrar Válvula'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _mqttService.closeValve();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comando de cierre enviado'),
            backgroundColor: AppColors.safe,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _valveStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado de la válvula
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    _isValveOpen ? Icons.lock_open : Icons.lock,
                    size: 80,
                    color: _isValveOpen ? AppColors.safe : AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isValveOpen ? '🔓 VÁLVULA ABIERTA' : '🔒 VÁLVULA CERRADA',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isValveOpen ? AppColors.safe : AppColors.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón de cerrar válvula
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isValveOpen ? _closeValve : null,
                      icon: const Icon(Icons.lock),
                      label: Text(
                        _isValveOpen ? 'CERRAR VÁLVULA' : 'VÁLVULA CERRADA',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValveOpen ? AppColors.danger : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Información importante
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Información Importante',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ La válvula SOLO puede cerrarse electrónicamente desde esta aplicación.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✋ La válvula debe abrirse manualmente después de verificar que el área es segura.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Configuración de cierre automático
          Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cierre Automático',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _autoClose,
                    onChanged: _toggleAutoClose,
                    title: Text(
                      'Cerrar automáticamente cuando PPM > 30',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _autoClose 
                          ? 'La válvula se cerrará automáticamente en caso de peligro'
                          : 'Solo cierre manual desde la app',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    activeColor: AppColors.safe,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

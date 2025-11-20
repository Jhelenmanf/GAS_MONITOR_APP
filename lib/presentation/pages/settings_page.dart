// ═══════════════════════════════════════════════════════════
// ⚙️ PÁGINA DE CONFIGURACIÓN
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/cleanup_service.dart';
import '../../services/mqtt_service.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/user.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final CleanupService _cleanupService = CleanupService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final MQTTService _mqttService = MQTTService();
  
  User? _currentUser;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _readingsCount = 0;
  double _storageSizeMB = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = await _authService.getLoggedInUser();
    final prefs = await SharedPreferences.getInstance();
    
    if (user != null) {
      final count = await _db.countUserReadings(user.id);
      final size = await _cleanupService.getHistorySizeInMB(user.id);
      
      setState(() {
        _currentUser = user;
        _notificationsEnabled = prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
        _soundEnabled = prefs.getBool(AppConstants.keySoundEnabled) ?? true;
        _vibrationEnabled = prefs.getBool(AppConstants.keyVibrationEnabled) ?? true;
        _readingsCount = count;
        _storageSizeMB = size;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotificationsEnabled, value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySoundEnabled, value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _toggleVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyVibrationEnabled, value);
    setState(() => _vibrationEnabled = value);
  }

  Future<void> _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Probando conexión...'),
        duration: Duration(seconds: 2),
      ),
    );

    // La conexión ya debería estar establecida desde MonitorPage
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mqttService.isConnected 
                ? '✅ Conexión exitosa' 
                : '❌ Error de conexión',
          ),
          backgroundColor: _mqttService.isConnected ? AppColors.safe : AppColors.danger,
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    if (_currentUser == null) return;

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
      final success = await _cleanupService.clearAllHistory(_currentUser!.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial eliminado'),
            backgroundColor: AppColors.safe,
          ),
        );
        await _loadSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Mi Perfil
          _buildSectionTitle('Mi Perfil'),
          _buildProfileCard(),
          
          const SizedBox(height: 24),

          // Notificaciones
          _buildSectionTitle('Notificaciones'),
          _buildNotificationsCard(),
          
          const SizedBox(height: 24),

          // Almacenamiento
          _buildSectionTitle('Almacenamiento'),
          _buildStorageCard(),
          
          const SizedBox(height: 24),

          // Conexión MQTT
          _buildSectionTitle('Conexión MQTT'),
          _buildConnectionCard(),
          
          const SizedBox(height: 24),

          // Información
          _buildSectionTitle('Información'),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_currentUser == null) return const SizedBox.shrink();

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.safe,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser!.nombre,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _currentUser!.usuarioFormateado,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.safe,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Último acceso',
              _currentUser!.lastLogin != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(_currentUser!.lastLogin!),
                    )
                  : 'N/A',
            ),
            _buildInfoRow(
              'Fecha de registro',
              DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(_currentUser!.createdAt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              title: const Text(
                'Activar notificaciones',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              activeColor: AppColors.safe,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? _toggleSound : null,
              title: const Text(
                'Sonido de alarma',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              activeColor: AppColors.safe,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _vibrationEnabled,
              onChanged: _notificationsEnabled ? _toggleVibration : null,
              title: const Text(
                'Vibración',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              activeColor: AppColors.safe,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Lecturas guardadas', '$_readingsCount'),
            _buildInfoRow('Tamaño', '${_storageSizeMB.toStringAsFixed(2)} MB'),
            _buildInfoRow('Retención', 'Últimas 10 horas'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearHistory,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Borrar Todo Mi Historial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              'Estado',
              _mqttService.isConnected ? 'Conectado' : 'Desconectado',
              valueColor: _mqttService.isConnected ? AppColors.safe : AppColors.danger,
            ),
            _buildInfoRow('Broker', 'HiveMQ Cloud'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.wifi),
                label: const Text('Probar Conexión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safe,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Versión de la app', AppConstants.appVersion),
            _buildInfoRow('Limpieza automática', '10 horas'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

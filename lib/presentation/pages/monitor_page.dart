// ═══════════════════════════════════════════════════════════
// 📊 PÁGINA DE MONITOREO PRINCIPAL
// ═══════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/mqtt_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/gas_reading.dart';
import '../../data/models/user.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/gas_gauge.dart';
import '../widgets/connection_indicator.dart';
import 'control_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'login_page.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  final MQTTService _mqttService = MQTTService();
  final AuthService _authService = AuthService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  User? _currentUser;
  GasReading? _lastReading;
  bool _isConnected = false;
  int _selectedIndex = 0;
  
  // Estadísticas
  double _promedio = 0.0;
  double _maximo = 0.0;
  int _alertasHoy = 0;
  
  StreamSubscription? _readingsSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Obtener usuario logueado
    _currentUser = await _authService.getLoggedInUser();
    if (_currentUser == null && mounted) {
      // No hay sesión, volver a login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    // Inicializar notificaciones
    await _notificationService.initialize();

    // Conectar a MQTT
    await _mqttService.connect(_currentUser!.id);

    // Suscribirse a streams
    _readingsSubscription = _mqttService.readingsStream.listen(_onNewReading);
    _connectionSubscription = _mqttService.connectionStream.listen(_onConnectionChange);

    // Cargar última lectura y estadísticas
    await _loadLastReading();
    await _loadStatistics();

    setState(() {});
  }

  void _onNewReading(GasReading reading) async {
    // Guardar en base de datos
    await _db.insertReading(reading);

    // Actualizar UI
    setState(() {
      _lastReading = reading;
    });

    // Actualizar estadísticas
    await _loadStatistics();

    // Enviar notificación si es necesario
    if (reading.nivelAlarma.index == 1) {
      // Precaución
      await _notificationService.showWarningNotification(reading.ppm);
    } else if (reading.nivelAlarma.index == 2) {
      // Peligro
      await _notificationService.showDangerNotification(reading.ppm);
    }
  }

  void _onConnectionChange(bool connected) {
    setState(() {
      _isConnected = connected;
    });

    if (!connected) {
      _notificationService.showDisconnectionNotification();
    }
  }

  Future<void> _loadLastReading() async {
    if (_currentUser == null) return;
    final reading = await _db.getLastReading(_currentUser!.id);
    setState(() {
      _lastReading = reading;
    });
  }

  Future<void> _loadStatistics() async {
    if (_currentUser == null) return;
    
    final stats = await _db.getReadingStats(_currentUser!.id);
    final alertas = await _db.countTodayAlerts(_currentUser!.id);
    
    setState(() {
      _promedio = stats['promedio'] ?? 0.0;
      _maximo = stats['maximo'] ?? 0.0;
      _alertasHoy = alertas;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _mqttService.disconnect();
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _readingsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  Widget _buildMonitorContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de conexión
          ConnectionIndicator(isConnected: _isConnected),
          const SizedBox(height: 24),

          // Gauge principal
          if (_lastReading != null)
            GasGauge(reading: _lastReading!)
          else
            _buildNoDataCard(),

          const SizedBox(height: 24),

          // Estadísticas
          _buildStatisticsCard(),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.sensors_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Esperando datos del sensor...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Promedio', '${_promedio.toStringAsFixed(1)} PPM', Icons.analytics),
                _buildStatItem('Máxima', '${_maximo.toStringAsFixed(1)} PPM', Icons.trending_up),
                _buildStatItem('Alertas Hoy', '$_alertasHoy', Icons.notifications),
              ],
            ),
            if (_lastReading != null) ...[
              const SizedBox(height: 16),
              Divider(color: AppColors.textSecondary.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'Última actualización: ${DateFormat('HH:mm:ss').format(_lastReading!.dateTime)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.safe, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMonitorContent(),
      const ControlPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: Text(
          'DetGas Monitor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.safe,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.safe,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 8),
                if (_currentUser != null) ...[
                  Text(
                    _currentUser!.nombre,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _currentUser!.usuarioFormateado,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart, color: AppColors.textPrimary),
            title: const Text('Monitor', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.control_camera, color: AppColors.textPrimary),
            title: const Text('Control de Válvula', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.textPrimary),
            title: const Text('Historial', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          const Divider(color: AppColors.textSecondary),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textPrimary),
            title: const Text('Configuración', style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          const Divider(color: AppColors.textSecondary),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.danger),
            title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.danger)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

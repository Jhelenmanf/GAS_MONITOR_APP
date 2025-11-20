// ═══════════════════════════════════════════════════════════
// 💾 HELPER DE BASE DE DATOS SQLite
// ═══════════════════════════════════════════════════════════

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/gas_reading.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Obtener instancia de base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  // Inicializar base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  // Crear tablas
  Future<void> _createDB(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        usuario TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        last_login INTEGER
      )
    ''');

    // Tabla de lecturas
    await db.execute('''
      CREATE TABLE lecturas (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        ppm REAL NOT NULL,
        valor_sensor INTEGER NOT NULL,
        gas_detectado INTEGER NOT NULL,
        nivel_alarma INTEGER NOT NULL,
        accion_tomada TEXT,
        usuario_id TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejor rendimiento
    await db.execute('CREATE INDEX idx_timestamp ON lecturas(timestamp)');
    await db.execute('CREATE INDEX idx_usuario ON lecturas(usuario_id)');
  }

  // ═══════════════════════════════════════════════════════════
  // OPERACIONES DE USUARIOS
  // ═══════════════════════════════════════════════════════════

  // Crear usuario
  Future<User> createUser(User user) async {
    final db = await database;
    await db.insert('usuarios', user.toMap());
    return user;
  }

  // Obtener usuario por username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Actualizar último login
  Future<void> updateLastLogin(String userId) async {
    final db = await database;
    await db.update(
      'usuarios',
      {'last_login': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Verificar si username existe
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // ═══════════════════════════════════════════════════════════
  // OPERACIONES DE LECTURAS
  // ═══════════════════════════════════════════════════════════

  // Insertar lectura
  Future<GasReading> insertReading(GasReading reading) async {
    final db = await database;
    await db.insert('lecturas', reading.toMap());
    return reading;
  }

  // Obtener lecturas de un usuario (últimas N horas)
  Future<List<GasReading>> getUserReadings(String usuarioId, {int hours = 10}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours)).millisecondsSinceEpoch;

    final maps = await db.query(
      'lecturas',
      where: 'usuario_id = ? AND timestamp >= ?',
      whereArgs: [usuarioId, cutoffTime],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => GasReading.fromMap(map)).toList();
  }

  // Obtener última lectura de un usuario
  Future<GasReading?> getLastReading(String usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'lecturas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return GasReading.fromMap(maps.first);
  }

  // Contar lecturas de un usuario
  Future<int> countUserReadings(String usuarioId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lecturas WHERE usuario_id = ?',
      [usuarioId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Limpiar lecturas antiguas (más de N horas)
  Future<int> cleanOldReadings(String usuarioId, {int hours = 10}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours)).millisecondsSinceEpoch;

    return await db.delete(
      'lecturas',
      where: 'usuario_id = ? AND timestamp < ?',
      whereArgs: [usuarioId, cutoffTime],
    );
  }

  // Borrar todas las lecturas de un usuario
  Future<int> deleteAllUserReadings(String usuarioId) async {
    final db = await database;
    return await db.delete(
      'lecturas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // Obtener estadísticas de lecturas
  Future<Map<String, double>> getReadingStats(String usuarioId) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 10)).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        AVG(ppm) as promedio,
        MAX(ppm) as maximo,
        COUNT(*) as total
      FROM lecturas
      WHERE usuario_id = ? AND timestamp >= ?
    ''', [usuarioId, cutoffTime]);

    if (result.isEmpty) {
      return {'promedio': 0.0, 'maximo': 0.0, 'total': 0.0};
    }

    final map = result.first;
    return {
      'promedio': (map['promedio'] as num?)?.toDouble() ?? 0.0,
      'maximo': (map['maximo'] as num?)?.toDouble() ?? 0.0,
      'total': (map['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // Contar alertas del día
  Future<int> countTodayAlerts(String usuarioId) async {
    final db = await database;
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM lecturas
      WHERE usuario_id = ? AND timestamp >= ? AND nivel_alarma > 0
    ''', [usuarioId, startOfDay]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

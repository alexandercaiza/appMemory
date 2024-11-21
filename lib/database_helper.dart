import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  // Obtén la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Si la base de datos aún no está abierta, la abrimos
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'memory_game.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Crea la tabla de puntos en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE points(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER
      )
    ''');
  }

  // Inserta un punto en la base de datos
  Future<void> insertScore(int score) async {
    final db = await database;
    await db.insert(
      'points',
      {'score': score},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtiene el total de puntos
  Future<int> getTotalPoints() async {
    final db = await database;
    var result = await db.query('points');
    int totalPoints = 0; // Asegúrate de que el total sea 0 al inicio
    for (var row in result) {
      totalPoints += row['score'] as int; // Asegúrate de que el valor sea int
    }
    return totalPoints; // Devuelve el total de puntos acumulados
  }
}

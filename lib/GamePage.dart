import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database Helper for SQLite
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // If the database is not opened, open it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'memory_game.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the points table in the database
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE points(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER
      )
    ''');
  }

  // Insert a score into the database
  Future<void> insertScore(int score) async {
    final db = await database;
    await db.insert(
      'points',
      {'score': score},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get the total points from the database
  Future<int?> getTotalPoints() async {
    final db = await database;
    var result = await db.query('points');
    int totalPoints = 0;
    for (var row in result) {
      totalPoints += row['score'] as int;
    }
    return totalPoints;
  }
}

// Main Application
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Memoria',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Estos son los íconos que permanecen fijos en los botones
  List<IconData> buttonIcons = [
    Icons.star,
    Icons.favorite,
    Icons.access_alarm,
    Icons.home,
    Icons.camera,
    Icons.music_note,
    Icons.search,
    Icons.local_pizza,
    Icons.beach_access,
  ];

  // Estos son los íconos que se mostrarán aleatoriamente para que el usuario los memorice
  List<IconData> randomGeneratedIcons = [];
  final Random _random = Random();
  bool showMessage = false;
  String message = '';
  int score = 0;
  int currentIconIndex =
      0; // Para hacer seguimiento del índice de los íconos que deben presionarse
  List<IconData> iconSequence = []; // Secuencia de íconos a recordar
  List<IconData> userPressSequence =
      []; // Secuencia de botones presionados por el usuario
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _generateRandomGeneratedIcons();
    _startIconsDisappear();
  }

  // Genera 3 íconos aleatorios para mostrar sobre el tablero
  void _generateRandomGeneratedIcons() {
    iconSequence = [
      buttonIcons[_random.nextInt(buttonIcons.length)],
      buttonIcons[_random.nextInt(buttonIcons.length)],
      buttonIcons[_random.nextInt(buttonIcons.length)],
    ];
    userPressSequence = []; // Reiniciamos la secuencia de presiones del usuario
    randomGeneratedIcons =
        List.from(iconSequence); // Los íconos que se muestran para memorizar
  }

  // Los íconos desaparecen después de 3 segundos
  void _startIconsDisappear() {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        randomGeneratedIcons
            .clear(); // Los íconos desaparecen después de 3 segundos
      });
    });
  }

  // Maneja la presión de un botón
  void _onButtonPressed(int index) {
    // Añadimos el ícono presionado a la secuencia del usuario
    setState(() {
      userPressSequence.add(buttonIcons[index]);

      // Verificamos si la secuencia del usuario es correcta
      if (userPressSequence.length == iconSequence.length) {
        if (listEquals(userPressSequence, iconSequence)) {
          setState(() {
            showMessage = true;
            message =
                '¡Felicidades! Has encontrado todos los íconos correctamente.';
            score += 1; // Aumentamos el puntaje en un intento exitoso
            dbHelper.insertScore(1); // Guardamos un puntaje de 1 por acierto
            _generateRandomGeneratedIcons(); // Generamos nuevos íconos para la siguiente ronda
            _startIconsDisappear(); // Reiniciamos la desaparición de íconos
            currentIconIndex =
                0; // Reiniciamos el índice para la siguiente ronda
          });

          // Ocultamos el mensaje después de 2 segundos
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              showMessage = false;
            });
          });
        } else {
          setState(() {
            showMessage = true;
            message = 'Perdiste. Intenta nuevamente.';
            score = 0; // Reiniciamos el puntaje en caso de perder
            dbHelper
                .insertScore(score); // Guardamos el puntaje en la base de datos
            _generateRandomGeneratedIcons(); // Generamos nuevos íconos para reintentar
            _startIconsDisappear(); // Reiniciamos la desaparición de íconos
            currentIconIndex =
                0; // Reiniciamos el índice para la siguiente ronda
          });

          // Ocultamos el mensaje después de 2 segundos
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              showMessage = false;
            });
          });
        }
      }
    });
  }

  // Recupera el puntaje total de la base de datos
  void _fetchTotalPoints() async {
    int? totalPoints = await dbHelper.getTotalPoints();
    setState(() {
      score = totalPoints ??
          0; // Actualizamos el puntaje con el total de la base de datos
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchTotalPoints(); // Recuperamos el puntaje total de la base de datos

    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Memoria'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostramos los íconos generados aleatoriamente encima del tablero
            if (randomGeneratedIcons.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: randomGeneratedIcons
                    .map((icon) => Icon(
                          icon,
                          size: 50,
                          color: Colors.blue,
                        ))
                    .toList(),
              ),
            SizedBox(height: 20),
            // Mostramos el mensaje
            if (showMessage)
              Text(
                message,
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
            SizedBox(height: 40),
            // Mostramos el puntaje
            Text(
              'Puntos: $score',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 20),
            // Tablero con 9 botones, cada uno con un ícono fijo
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => _onButtonPressed(index),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.blue[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    buttonIcons[index], // Los íconos de los botones son fijos
                    size: 40,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

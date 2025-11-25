import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/speech_history.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'teleprompter.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE speech_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            duration_seconds INTEGER NOT NULL,
            word_count INTEGER NOT NULL,
            score INTEGER NOT NULL,
            script_title TEXT NOT NULL,
            ktv_deviation REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertHistory(SpeechHistory history) async {
    final db = await database;
    return await db.insert('speech_history', history.toMap());
  }

  Future<List<SpeechHistory>> getRecentHistory({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'speech_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return SpeechHistory.fromMap(maps[i]);
    });
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete(
      'speech_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

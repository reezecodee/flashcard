import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton Pattern: memastikan hanya ada 1 instance class ini di seluruh app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // getter untuk mengambil object database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('flashcard.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version:
          1, // naikkan versi ini jika nanti mengubah struktur tabel (migrasi)
      onCreate: _createDB,
      onConfigure: _onConfigure, // penting untuk mengaktifkan foreign key
    );
  }

  // mengaktifkan fitur foreign key di sqlite (defaultnya mati)
  Future _onConfigure(Database db) async {
    await db.execute('FRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Tipe data SQLite vs Dart:
    // INTEGER -> int
    // TEXT    -> String
    // REAL    -> double

    // 1. table decks
    await db.execute('''
    CREATE TABLE decks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
    ''');

    // 2. table cards
    // pakai ON DELETE CASCADE di foreign key deck_id
    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      deck_id INTEGER NOT NULL,
      front TEXT NOT NULL,
      back TEXT NOT NULL,
      interval INTEGER NOT NULL,
      ease_factor REAL NOT NULL,
      due_date INTEGER NOT NULL,
      review_count INTEGER NOT NULL,
      FOREIGN KEY (deck_id) REFERENCES (decks) (id) ON DELETE CASCADE
    )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

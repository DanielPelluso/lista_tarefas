import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class TaskDatabase {
  TaskDatabase._();

  static final TaskDatabase instance = TaskDatabase._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

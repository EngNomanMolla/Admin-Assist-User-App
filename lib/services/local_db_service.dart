import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'mentor_assist_todos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY,
        title TEXT,
        notes TEXT,
        repeat TEXT,
        due_date TEXT,
        status TEXT
      )
    ''');
  }

  Future<void> upsertTodo(Map<String, dynamic> todo) async {
    final db = await database;
    await db.insert(
      'todos',
      {
        'id': int.tryParse(todo['id'].toString()) ?? 0,
        'title': todo['title'],
        'notes': todo['notes'],
        'repeat': todo['repeat'],
        'due_date': todo['due_date'],
        'status': todo['status'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final db = await database;
    return await db.query('todos');
  }
}

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const String _databaseName = "expense_tracker.db";
  static const String tableName = "transactions";
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = path.join(databaseDirectory, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            category TEXT NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    return db.insert(
      tableName,
      transaction.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<ExpenseTransaction>> getTransactions() async {
    final db = await database;
    final rows = await db.query(
      tableName,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  Future<ExpenseTransaction?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return ExpenseTransaction.fromMap(rows.first);
  }

  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError('A transaction ID is required for an update.');
    }

    final db = await database;
    final values = transaction.toMap()..remove('id');
    return db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

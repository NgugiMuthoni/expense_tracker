import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import '../models/entry_models.dart';
import '../models/user_model.dart';

class DBService extends ChangeNotifier {
  Database? _database;

  // Initialize the database factory for desktop platforms
  DBService() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Handle database upgrades
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount REAL,
      date TEXT,
      userId INTEGER,
      isIncome INTEGER DEFAULT 0,  -- New column to store if entry is income or expense
      FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new column if the old version is less than 2
      await db
          .execute('ALTER TABLE entries ADD COLUMN isIncome INTEGER DEFAULT 0');
    }
  }

  // User-related methods

  Future<int?> registerUser(User user) async {
    final db = await database;

    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return null; // Username might already exist
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Entry-related methods

  Future<void> insertEntry(Entry entry) async {
    final db = await database;

    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners(); // Notify listeners of changes
  }

  Future<List<Entry>> getEntries(int userId) async {
    final db = await database;

    final result = await db.query('entries',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'date ASC');

    return result.map((json) => Entry.fromMap(json)).toList();
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;

    await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners(); // Notify listeners of changes
  }

  // Method to retrieve entries for statistics
  Future<List<Entry>> getEntriesForStatistics(int userId) async {
    final db = await database;

    final result = await db.query(
      'entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC', // Order by date descending
    );

    return result.map((json) => Entry.fromMap(json)).toList();
  }
}

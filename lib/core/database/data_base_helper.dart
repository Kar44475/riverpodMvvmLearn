import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'temp_readings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE temp_readings (
        id INTEGER PRIMARY KEY,
        reading REAL NOT NULL,
        image BLOB,
        longitude REAL NOT NULL,
        latitude REAL NOT NULL,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');
  }


  Future<void> insertTempReading({
    required int id,
    required double reading,
    required Uint8List imageBytes,
    required double longitude,
    required double latitude,
  }) async {
    final db = await database;
    await db.insert(
      'temp_readings',
      {
        'id': id,
        'reading': reading,
        'image': imageBytes.isNotEmpty ? imageBytes : null,
        'longitude': longitude,
        'latitude': latitude,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Map<String, dynamic>>> getAllTempReadings() async {
    final db = await database;
    final results = await db.query('temp_readings', orderBy: 'created_at ASC');
    

    return results.map((row) {
      final Map<String, dynamic> processedRow = Map.from(row);
      if (processedRow['image'] != null) {
        processedRow['image'] = processedRow['image'] as Uint8List;
      }
      return processedRow;
    }).toList();
  }


  Future<int> getPendingReadingsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM temp_readings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

 
  Future<void> deleteTempReading(int id) async {
    final db = await database;
    await db.delete('temp_readings', where: 'id = ?', whereArgs: [id]);
  }


  Future<void> clearTempReadings() async {
    final db = await database;
    await db.delete('temp_readings');
  }

 

  


  Future<void> updateTempReading({
    required int id,
    required double reading,
    required Uint8List imageBytes,
    required double longitude,
    required double latitude,
  }) async {
    final db = await database;
    await db.update(
      'temp_readings',
      {
        'reading': reading,
        'image': imageBytes.isNotEmpty ? imageBytes : null,
        'longitude': longitude,
        'latitude': latitude,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }


}
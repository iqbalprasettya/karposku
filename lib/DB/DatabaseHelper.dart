import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'faces.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE faces (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            left REAL,
            top REAL,
            right REAL,
            bottom REAL,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFaceData(Map<String, dynamic> faceData) async {
    final db = await database;
    await db.insert('faces', faceData);
  }

  // Get the records
  Future<List<Map>> getFaceData() async {
    final db = await database;
    List<Map> list = await db.rawQuery('SELECT * FROM faces');
    // List<Map> expectedList = [
    //   {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
    //   {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
    // ];

    print(list);
    return list;
    // print(expectedList);
    // assert(const DeepCollectionEquality().equals(list, expectedList));
  }

  Future<void> deleteFaceData(int faceId) async {
    final db = await database;
    // Delete a record
    int count = await db.rawDelete('DELETE FROM faces WHERE id = ?', [faceId]);
    assert(count == 1);
  }
}

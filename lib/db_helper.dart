import 'package:path/path.dart';
import 'package:visitor_qr_code_scanner/model/model_db.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "vistor.db";
  static const _databaseVersion = 1;

  static const table = 'tbl_visitor';
  static const columnId = 'id';
 // static const columnPrefix = 'prefix';
  static const columnName = 'name';
  static const columnPosition = 'position';
  static const columnCompany = 'company';
  static const columnType = 'type';
  static const columnEmail = 'email';
  static const columnPhone = 'phone';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnPosition TEXT NOT NULL,
            $columnCompany TEXT NOT NULL,
            $columnType TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPhone TEXT NOT NULL
          )
          ''');
  }

  Future<void> insertQR(ModelDB qr) async {
    final db = await database;
    await db?.insert(
      table,
      qr.toMap(),
    );
  }

  Future<List<ModelDB>> queryAllRows() async {
    Database? db = await instance.database;
    final maps = await db?.query(table);
    return List.generate(maps!.length, (index) {
      return ModelDB.fromMap(maps[index]);
    });
  }

  rawDelete(String s) {}

  Future<void> delete() async {
    final db = await database;
    await db?.delete(table);
  }
}

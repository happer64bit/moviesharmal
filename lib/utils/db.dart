import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "appDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'movies';
  static const columnId = 'id';
  static const columnMovieId = 'movie_id';
  static const columnType = 'type';
  static const columnTitle = 'title';
  static const columnBackdropPath = 'backdrop_path';
  static const columnCreatedAt = 'createdAt';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnMovieId INTEGER NOT NULL,
            $columnType TEXT NOT NULL,
            $columnTitle TEXT NOT NULL,
            $columnBackdropPath TEXT,
            $columnCreatedAt TEXT DEFAULT (datetime('now'))
          )
        ''');
      },
    );
  }

  Future<int> addFavoriteMovie(Map<String, dynamic> movie) async {
    final db = await database;
    return await db.insert(table, movie, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeFavoriteMovie(int movieId) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnMovieId = ?',
      whereArgs: [movieId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteMovies() async {
    final db = await database;
    return await db.query(table);
  }

}

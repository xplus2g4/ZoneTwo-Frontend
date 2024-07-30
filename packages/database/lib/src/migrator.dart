import 'package:sqflite/sqflite.dart';

class DatabaseMigrator {
  const DatabaseMigrator(this._db_path);
  final String _db_path;

  void _onConfigure(Database db) {
    db.execute('PRAGMA foreign_keys = ON');
  }

  void _schemaV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS music');
    batch.execute('''
      CREATE TABLE music (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        save_path TEXT NOT NULL,
        bpm REAL NOT NULL,
        cover_image BLOB NOT NULL
  )''');
    batch.execute('DROP TABLE IF EXISTS playlists');
    batch.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cover_image BLOB
      )
    ''');
    batch.execute('DROP TABLE IF EXISTS playlist_music');
    batch.execute('''
      CREATE TABLE playlist_music (
        id TEXT PRIMARY KEY,
        playlist_id TEXT NOT NULL,
        music_id TEXT NOT NULL,
        FOREIGN KEY(playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY(music_id) REFERENCES music(id) ON DELETE CASCADE
      )
    ''');
    batch.execute('DROP TABLE IF EXISTS workouts');
    batch.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        datetime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        distance REAL NOT NULL
      )
    ''');
    batch.execute('DROP TABLE IF EXISTS workout_points');
    //for next time...
    batch.execute('''
      CREATE TABLE workout_points (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        order_priority INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        FOREIGN KEY(workout_id) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> open() async {
    final db = await openDatabase(_db_path,
        version: 1, onConfigure: _onConfigure, onCreate: (db, version) async {
      var batch = db.batch();
      _schemaV1(batch);
      await batch.commit();
    }, onDowngrade: onDatabaseDowngradeDelete);
    return db;
  }
}

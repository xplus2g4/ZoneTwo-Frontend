import 'package:sqflite/sqflite.dart';

class DatabaseMigrator {
  const DatabaseMigrator(this._db_path);
  final String _db_path;

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
  }

  Future<Database> open() async {
    final db =
        await openDatabase(_db_path, version: 1, onCreate: (db, version) async {
      var batch = db.batch();
      _schemaV1(batch);
      await batch.commit();
    }, onDowngrade: onDatabaseDowngradeDelete);
    return db;
  }
}

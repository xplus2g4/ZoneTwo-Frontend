import 'package:sqflite/sqflite.dart';

class DatabaseMigrator {
  const DatabaseMigrator(this._db_path);
  final String _db_path;

  void _schemaV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS musics');
    batch.execute('''CREATE TABLE musics (
      id TEXT PRIMARY KEY,
      title TEXT,
      save_path TEXT,
      bpm REAL
  )''');
  }

  Future<Database> open() async {
    final db =
        await openDatabase(_db_path, version: 1, onCreate: (db, version) async {
      var batch = db.batch();
      _schemaV1(batch);
      await batch.commit();
    }, onDowngrade: onDatabaseDowngradeDelete);
    await db.execute('DROP TABLE IF EXISTS musics');
    await db.execute('''CREATE TABLE musics (
      id TEXT PRIMARY KEY,
      title TEXT,
      save_path TEXT,
      bpm REAL
  )''');
    return db;
  }
}

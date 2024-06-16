import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:music_repository/music_repository.dart';
import 'package:uuid/v4.dart';

class MusicRepository {
  static const tableName = "musics";
  const MusicRepository(this._db);

  final Database _db;

  Future<MusicData> addMusicData(MusicData music) async {
    final newId = const UuidV4().generate();
    await _db.rawInsert(
        "INSERT INTO $tableName(id, title, save_path, bpm) VALUES(?, ?, ?, ?)",
        [
          newId,
          music.title,
          music.savePath,
          music.bpm,
        ]);
    return music.update(id: newId);
  }

  Future<List<MusicData>> getAllMusicData() async {
    return (await _db.query(tableName)).map(MusicData.fromRow).toList();
  }

  Future<MusicData?> getMusicDataById(String id) async {
    final rawRow =
        (await _db.query(tableName, where: "id = ?", whereArgs: [id])).first;
    return MusicData.fromRow(rawRow);
  }

  Future<void> updateMusicData(MusicData music) async {
    await _db.rawUpdate(
        "UPDATE $tableName SET title = ?, save_path = ? bpm = ? WHERE id = ?", [
      music.title,
      music.savePath,
      music.bpm,
      music.id,
    ]);
  }

  Future<void> deleteMusicData(MusicData music) async {
    await _db.delete(tableName, where: "id = ?", whereArgs: [music.id]);
  }
}

import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:music_repository/music_repository.dart';
import 'package:uuid/v4.dart';
import 'package:rxdart/subjects.dart';

class MusicRepository {
  static const tableName = "musics";
  MusicRepository(this._db);

  final Database _db;
  late final _musicStreamController = BehaviorSubject<List<MusicData>>.seeded(
    const [],
  );

  Stream<List<MusicData>> getMusics() =>
      _musicStreamController.asBroadcastStream();

  Future<void> addMusicData(MusicData music) async {
    // Update database
    final newId = const UuidV4().generate();
    await _db.rawInsert(
        "INSERT INTO $tableName(id, title, save_path, bpm, cover_image) VALUES(?, ?, ?, ?, ?)",
        [
          newId,
          music.title,
          music.savePath,
          music.bpm,
          music.coverImage,
        ]);
    final musics = [..._musicStreamController.value];
    final newMusic = music.update(id: newId);
    musics.add(newMusic);
    _musicStreamController.add(musics);
  }

  Future<void> getAllMusicData() async {
    final musics = (await _db.query(tableName)).map(MusicData.fromRow).toList();
    _musicStreamController.add(musics);
  }

  Future<void> updateMusicData(MusicData music) async {
    // Update database
    await _db.rawUpdate(
        "UPDATE $tableName SET title = ?, save_path = ? bpm = ? WHERE id = ?", [
      music.title,
      music.savePath,
      music.bpm,
      music.id,
    ]);

    // Publish to stream
    final musics = [..._musicStreamController.value];
    final musicIndex = musics.indexWhere((t) => t.id == music.id);
    if (musicIndex >= 0) {
      musics[musicIndex] = music;
    } else {
      musics.add(music);
    }
    _musicStreamController.add(musics);
  }

  Future<void> deleteMusicData(MusicData music) async {
    // Update database
    await _db.delete(tableName, where: "id = ?", whereArgs: [music.id]);

    // Publish to stream
    final musics = [..._musicStreamController.value];
    final musicIndex = musics.indexWhere((t) => t.id == music.id);
    if (musicIndex == -1) {
      // TODO: Handle Error
    } else {
      musics.removeAt(musicIndex);
      _musicStreamController.add(musics);
    }
  }
}

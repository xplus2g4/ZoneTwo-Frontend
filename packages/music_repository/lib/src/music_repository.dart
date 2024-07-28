import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:music_repository/music_repository.dart';
import 'package:uuid/v4.dart';
import 'package:rxdart/subjects.dart';

class MusicRepository {
  static const tableName = "music";
  MusicRepository(this._db);

  final Database _db;
  late final _musicStreamController = BehaviorSubject<List<MusicData>>.seeded(
    const [],
  );

  Stream<List<MusicData>> getMusic() =>
      _musicStreamController.asBroadcastStream();

  Future<void> addMusicData(MusicData musicData) async {
    // Update database
    final newId = const UuidV4().generate();
    await _db.rawInsert(
        "INSERT INTO $tableName(id, title, save_path, bpm, cover_image) VALUES(?, ?, ?, ?, ?)",
        [
          newId,
          musicData.title,
          musicData.savePath,
          musicData.bpm,
          musicData.coverImage,
        ]);
    final music = [..._musicStreamController.value];
    final newMusic = musicData.update(id: newId);
    music.add(newMusic);
    _musicStreamController.add(music);
  }

  Future<void> getAllMusicData() async {
    final music = (await _db.query(tableName)).map(MusicData.fromRow).toList();
    _musicStreamController.add(music);
  }

  Future<void> updateMusicData(MusicData musicData) async {
    // Update database
    await _db.rawUpdate(
        "UPDATE $tableName SET title = ?, save_path = ? bpm = ? WHERE id = ?", [
      musicData.title,
      musicData.savePath,
      musicData.bpm,
      musicData.id,
    ]);

    // Publish to stream
    final music = [..._musicStreamController.value];
    final musicIndex = music.indexWhere((t) => t.id == musicData.id);
    if (musicIndex >= 0) {
      music[musicIndex] = musicData;
    } else {
      music.add(musicData);
    }
    _musicStreamController.add(music);
  }

  Future<void> deleteMusicData(List<MusicData> musicData) async {
    final musicIds = musicData.map((music) => music.id).toList();
    final queryPlaceholder = List.filled(musicIds.length, '?').join(',');
    await _db.delete(tableName,
        where: "id IN ($queryPlaceholder)", whereArgs: musicIds);
    final music = _musicStreamController.value
        .where((music) => !musicData.contains(music))
        .toList();
    _musicStreamController.add(music);
  }
}

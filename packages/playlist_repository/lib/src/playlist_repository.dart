import 'dart:async';

import 'package:music_repository/music_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/v4.dart';
import 'package:rxdart/subjects.dart';

import 'data_models/data_models.dart';

class PlaylistRepository {
  static const tableName = "playlists";
  static const joinTableName = "playlist_music";
  PlaylistRepository(this._db);

  final Database _db;
  late final _playlistStreamController =
      BehaviorSubject<List<PlaylistData>>.seeded(
    const [],
  );
  late final _playlistWithmusictreamController =
      BehaviorSubject<PlaylistWithMusicData>();

  Stream<List<PlaylistData>> getPlaylistsStream() =>
      _playlistStreamController.asBroadcastStream();

  Stream<PlaylistWithMusicData> getPlaylistWithmusictream() =>
      _playlistWithmusictreamController.asBroadcastStream();

  Future<void> addMusicToPlaylist(
      List<MusicData> music, PlaylistData playlist) async {
    // Update database
    await _db.transaction((txn) async {
      await txn.rawUpdate('''
        UPDATE $tableName SET song_count = song_count + ?
        WHERE id = ?
      ''', [music.length, playlist.id]);
      await txn.rawInsert('''
        INSERT INTO $joinTableName (playlist_id, music_id)
        VALUES ${music.map((music) => "(${playlist.id}, ${music.id})").join(", ")}
      ''');
    });
    final playlistWithMusic = _playlistWithmusictreamController.value;
    if (playlistWithMusic.id == playlist.id) {
      _playlistWithmusictreamController.add(
        playlistWithMusic
            .updateData(music: [...playlistWithMusic.music, ...music]),
      );
    }
  }

  Future<void> createPlaylist(PlaylistWithMusicData playlist) async {
    // Update database
    final newId = const UuidV4().generate();
    await _db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO $tableName (id, name, song_count, cover_image)
        VALUES (?, ?, ?, ?)
      ''', [newId, playlist.name, playlist.music.length, playlist.coverImage]);

      await txn.rawInsert('''
        INSERT INTO $joinTableName (playlist_id, music_id)
        VALUES ${playlist.music.map((music) => "('$newId', '${music.id}')").join(", ")}
      ''');
    });

    // Publish to stream
    final playlists = [..._playlistStreamController.value];
    final playlistIndex = playlists.indexWhere((t) => t.id == playlist.id);
    if (playlistIndex >= 0) {
      playlists[playlistIndex] = playlist;
    } else {
      playlists.add(playlist);
    }
    _playlistStreamController.add(playlists);

    _playlistWithmusictreamController.add(
      PlaylistWithMusicData(
        id: newId,
        name: playlist.name,
        music: playlist.music,
      ),
    );
  }

  Future<void> getAllPlaylists() async {
    final playlists =
        (await _db.query(tableName)).map(PlaylistData.fromRow).toList();
    _playlistStreamController.add(playlists);
  }

  Future<void> getPlaylistWithMusic(PlaylistData playlist) async {
    final music = (await _db.rawQuery('''
      SELECT * FROM $joinTableName
      JOIN ${MusicRepository.tableName} ON $joinTableName.music_id = ${MusicRepository.tableName}.id
      WHERE playlist_id = ?
    ''', [playlist.id])).map(MusicData.fromRow).toList();
    _playlistWithmusictreamController.add(PlaylistWithMusicData(
      id: playlist.id,
      name: playlist.name,
      music: music,
    ));
  }

  Future<void> updatePlaylistData(PlaylistData playlist) async {
    // Update database
    await _db.rawUpdate('''
      UPDATE $tableName
      SET name = ?, cover_image = ?
      WHERE id = ?
    ''', [playlist.name, playlist.coverImage, playlist.id]);

    // Publish to stream
    final playlists = [..._playlistStreamController.value];
    final playlistIndex = playlists.indexWhere((t) => t.id == playlist.id);
    if (playlistIndex >= 0) {
      playlists[playlistIndex] = playlist;
    } else {
      playlists.add(playlist);
    }
    _playlistStreamController.add(playlists);

    if (_playlistWithmusictreamController.value.id == playlist.id) {
      _playlistWithmusictreamController.add(
        _playlistWithmusictreamController.value.updateData(
          name: playlist.name,
        ),
      );
    }
  }

  Future<void> deletePlaylist(PlaylistData playlist) async {
    // Update database
    await _db.delete(tableName, where: "id = ?", whereArgs: [playlist.id]);

    // Publish to stream
    final playlists = [..._playlistStreamController.value];
    final playlistIndex = playlists.indexWhere((t) => t.id == playlist.id);
    if (playlistIndex == -1) {
      // TODO: Handle Error
    } else {
      playlists.removeAt(playlistIndex);
      _playlistStreamController.add(playlists);
    }
  }
}

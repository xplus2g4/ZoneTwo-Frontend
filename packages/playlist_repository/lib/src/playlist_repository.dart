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

  Stream<PlaylistWithMusicData> getPlaylistWithMusicStream() =>
      _playlistWithmusictreamController.asBroadcastStream();

  Future<void> createPlaylist(PlaylistWithMusicData playlist) async {
    // Update database
    final newId = const UuidV4().generate();
    await _db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO $tableName (id, name, cover_image)
        VALUES (?, ?, ?)
      ''', [newId, playlist.name, playlist.coverImage]);

      await txn.rawInsert('''
        INSERT INTO $joinTableName (playlist_id, music_id)
        VALUES ${playlist.music.map((music) => "('$newId', '${music.id}')").join(", ")}
      ''');
    });
    playlist = playlist.updateData(id: newId);

    // Publish to stream
    final playlists = [..._playlistStreamController.value, playlist];
    _playlistStreamController.add(playlists);
  }

  Future<void> getAllPlaylists() async {
    final playlistFutures = (await _db.query(tableName)).map((row) async {
      final songCount = (await _db.rawQuery('''
          SELECT COUNT(*) AS song_count FROM $joinTableName
          WHERE playlist_id = ?
        ''', [row['id']]))[0]['song_count'] as int;
      return PlaylistData.fromRow(row, songCount: songCount);
    });
    final playlists = await Future.wait(playlistFutures);
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

  Future<void> updatePlaylistMusic(PlaylistWithMusicData playlist) async {
    // Update database
    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM $joinTableName
        WHERE playlist_id = ?
      ''', [playlist.id]);

      if (playlist.music.isEmpty) {
        return;
      }

      await txn.rawInsert('''
        INSERT INTO $joinTableName (playlist_id, music_id)
        VALUES ${playlist.music.map((music) => "('${playlist.id}', '${music.id}')").join(", ")}
      ''');
    });

    // Publish to stream
    _playlistWithmusictreamController.add(playlist);
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

import 'dart:typed_data';

import 'package:music_repository/music_repository.dart';

class PlaylistData {
  final String id;
  final String name;
  final int songCount;
  final Uint8List? coverImage;

  const PlaylistData({
    required this.id,
    required this.name,
    required this.songCount,
    this.coverImage,
  });

  PlaylistData.newData(
      {required this.name, required this.songCount, this.coverImage})
      : id = "";

  factory PlaylistData.fromRow(Map<String, Object?> row) {
    return PlaylistData(
      id: row['id'] as String,
      name: row['name'] as String,
      songCount: row['song_count'] as int,
      coverImage: row['cover_image'] as Uint8List?,
    );
  }

  PlaylistData update(
      {String? id, String? name, int? songCount, Uint8List? coverImage}) {
    return PlaylistData(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'name': name,
      'song_count': songCount,
      'cover_image': coverImage,
    };
  }

  @override
  String toString() {
    return 'Playlist{id: $id, title: $name, songCount: $songCount}';
  }
}

class PlaylistWithMusicData extends PlaylistData {
  final List<MusicData> music;

  const PlaylistWithMusicData({
    required super.id,
    required super.name,
    required this.music,
    super.coverImage,
  }) : super(songCount: music.length);

  PlaylistWithMusicData updateData(
      {String? id,
      String? name,
      List<MusicData>? music,
      Uint8List? coverImage}) {
    return PlaylistWithMusicData(
      id: id ?? this.id,
      name: name ?? this.name,
      music: music ?? this.music,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  @override
  String toString() {
    return 'PlaylistWithMusicData{id: $id, name: $name, music: $music}';
  }
}

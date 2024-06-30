import 'package:music_repository/music_repository.dart';

class PlaylistData {
  final String id;
  final String name;

  const PlaylistData({
    required this.id,
    required this.name,
  });

  PlaylistData.newData({
    required this.name,
  }) : id = "";

  factory PlaylistData.fromRow(Map<String, Object?> row) {
    return PlaylistData(
      id: row['id'] as String,
      name: row['name'] as String,
    );
  }

  PlaylistData update({String? id, String? name, num? bpm}) {
    return PlaylistData(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Playlist{id: $id, title: $name}';
  }
}

class PlaylistWithMusicData extends PlaylistData {
  final List<MusicData> musics;

  const PlaylistWithMusicData({
    required super.id,
    required super.name,
    required this.musics,
  });

  @override
  PlaylistWithMusicData update(
      {String? id, String? name, num? bpm, List<MusicData>? musics}) {
    return PlaylistWithMusicData(
      id: id ?? this.id,
      name: name ?? this.name,
      musics: musics ?? this.musics,
    );
  }

  @override
  String toString() {
    return 'PlaylistWithMusicData{id: $id, name: $name, musics: $musics}';
  }
}

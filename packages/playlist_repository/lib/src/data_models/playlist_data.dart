import 'package:music_repository/music_repository.dart';

class PlaylistData {
  final String id;
  final String name;
  final int songCount;

  const PlaylistData({
    required this.id,
    required this.name,
    required this.songCount,
  });

  PlaylistData.newData({
    required this.name,
  })  : id = "",
        songCount = 0;

  factory PlaylistData.fromRow(Map<String, Object?> row) {
    return PlaylistData(
      id: row['id'] as String,
      name: row['name'] as String,
      songCount: row['song_count'] as int,
    );
  }

  PlaylistData update({String? id, String? name, int? songCount}) {
    return PlaylistData(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'name': name,
      'song_count': songCount,
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
  }) : super(songCount: musics.length);

  PlaylistWithMusicData updateData(
      {String? id, String? name, List<MusicData>? musics}) {
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

import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

import 'playlist_entity.dart';

class PlaylistWithMusicsEntity extends PlaylistEntity {
  final List<MusicEntity> musics;

  const PlaylistWithMusicsEntity({
    required super.id,
    required super.name,
    required this.musics,
  }) : super(songCount: musics.length);

  @override
  PlaylistWithMusicData toData() {
    return PlaylistWithMusicData(
      id: id,
      name: name,
      musics: musics.map((e) => e.toData()).toList(),
    );
  }

  factory PlaylistWithMusicsEntity.newPlaylist(
      {required String name, required List<MusicEntity> musics}) {
    return PlaylistWithMusicsEntity(
      id: "",
      name: name,
      musics: musics,
    );
  }
}

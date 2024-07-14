import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

import 'playlist_entity.dart';

class PlaylistWithMusicEntity extends PlaylistEntity {
  final List<MusicEntity> music;

  const PlaylistWithMusicEntity({
    required super.id,
    required super.name,
    required this.music,
  }) : super(songCount: music.length);

  @override
  PlaylistWithMusicData toData() {
    return PlaylistWithMusicData(
      id: id,
      name: name,
      music: music.map((e) => e.toData()).toList(),
    );
  }

  factory PlaylistWithMusicEntity.newPlaylist(
      {required String name, required List<MusicEntity> music}) {
    return PlaylistWithMusicEntity(
      id: "",
      name: name,
      music: music,
    );
  }
}

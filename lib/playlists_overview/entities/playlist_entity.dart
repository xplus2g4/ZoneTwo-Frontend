import 'package:playlist_repository/playlist_repository.dart';

class PlaylistEntity {
  final String id;
  final String name;
  final int songCount;

  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.songCount,
  });

  factory PlaylistEntity.fromData(PlaylistData data) {
    return PlaylistEntity(
      id: data.id,
      name: data.name,
      songCount: data.songCount,
    );
  }

  PlaylistData toData() {
    return PlaylistData(
      id: id,
      name: name,
      songCount: songCount,
    );
  }
}

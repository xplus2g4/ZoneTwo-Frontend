import 'package:playlist_repository/playlist_repository.dart';

class PlaylistEntity {
  final String id;
  final String name;

  const PlaylistEntity({
    required this.id,
    required this.name,
  });

  factory PlaylistEntity.fromData(PlaylistData data) {
    return PlaylistEntity(
      id: data.id,
      name: data.name,
    );
  }
}

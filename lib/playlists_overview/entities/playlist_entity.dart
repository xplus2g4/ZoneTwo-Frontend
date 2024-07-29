import 'dart:typed_data';

import 'package:playlist_repository/playlist_repository.dart';

class PlaylistEntity {
  final String id;
  final String name;
  final int songCount;
  final Uint8List? coverImage;
  
  // ignore: constant_identifier_names
  static const ALL_MUSIC = PlaylistEntity(
    id: "All Music",
    name: "All Music",
    songCount: -1,
  );

  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.songCount,
    this.coverImage,
  });

  factory PlaylistEntity.fromData(PlaylistData data) {
    return PlaylistEntity(
      id: data.id,
      name: data.name,
      songCount: data.songCount,
      coverImage: data.coverImage,
    );
  }

  PlaylistData toData() {
    return PlaylistData(
      id: id,
      name: name,
      songCount: songCount,
      coverImage: coverImage,
    );
  }
}

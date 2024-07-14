import 'dart:typed_data';

import 'package:music_repository/music_repository.dart';

// Note to whoever sees this,
// By clean architecture, it should be MusicData extends MusicEntity.
class MusicEntity {
  final String id;
  final String title;
  final num bpm;
  final Uint8List coverImage;
  final String savePath;

  const MusicEntity({
    required this.id,
    required this.title,
    required this.savePath,
    required this.bpm,
    required this.coverImage,
  });

  factory MusicEntity.fromData(MusicData data) {
    return MusicEntity(
      id: data.id,
      title: data.title,
      savePath: data.savePath,
      bpm: data.bpm,
      coverImage: data.coverImage,
    );
  }

  MusicData toData() {
    return MusicData(
      id: id,
      title: title,
      savePath: savePath,
      bpm: bpm,
      coverImage: coverImage,
    );
  }
}

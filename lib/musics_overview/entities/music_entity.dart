import 'package:music_repository/music_repository.dart';

// Note to whoever sees this,
// By clean architecture, it should be MusicData extends MusicEntity.
class MusicEntity {
  final String id;
  final String title;
  final num bpm;
  final String savePath;

  const MusicEntity({
    required this.id,
    required this.title,
    required this.savePath,
    required this.bpm,
  });

  factory MusicEntity.fromData(MusicData data) {
    return MusicEntity(
      id: data.id,
      title: data.title,
      savePath: data.savePath,
      bpm: data.bpm,
    );
  }
}

import 'dart:typed_data';

class MusicDownloadInfo {
  const MusicDownloadInfo({
    required this.title,
    required this.savePath,
    required this.bpm,
    required this.coverImage,
  });

  final String title;
  final num bpm;
  final Uint8List coverImage;
  final String savePath;
}

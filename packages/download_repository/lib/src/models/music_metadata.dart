import 'dart:typed_data';

class MusicMetadata {
  const MusicMetadata({
    required this.image,
    required this.bpm,
  });

  final Uint8List image;
  final num bpm;
}

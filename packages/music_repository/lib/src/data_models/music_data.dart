import 'dart:typed_data';

class MusicData {
  final String id;
  final String title;
  final num bpm;
  final Uint8List coverImage;
  final String savePath;

  const MusicData({
    required this.id,
    required this.title,
    required this.savePath,
    required this.bpm,
    required this.coverImage,
  });

  const MusicData.newData({
    required this.title,
    required this.savePath,
    required this.bpm,
    required this.coverImage,
  }) : id = "";

  factory MusicData.fromRow(Map<String, Object?> row) {
    return MusicData(
      id: row['id'] as String,
      title: row['title'] as String,
      savePath: row['save_path'] as String,
      bpm: row['bpm'] as num,
      coverImage: row['cover_image'] as Uint8List,
    );
  }

  MusicData update({String? id, String? title, String? savePath, double? bpm}) {
    return MusicData(
      id: id ?? this.id,
      title: title ?? this.title,
      savePath: savePath ?? this.savePath,
      bpm: bpm ?? this.bpm,
      coverImage: coverImage,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'title': title,
      'bpm': bpm,
      'save_path': savePath,
      'cover_image': coverImage,
    };
  }

  @override
  String toString() {
    return 'Music{id: $id, title: $title}';
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is MusicData && other.id == id;
  }
}

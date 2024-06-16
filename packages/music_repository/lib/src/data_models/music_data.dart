import 'package:flutter/foundation.dart';

class MusicData {
  final String id;
  final String title;
  final num bpm;
  final String savePath;

  const MusicData({
    required this.id,
    required this.title,
    required this.savePath,
    required this.bpm,
  });

  const MusicData.newData({
    required this.title,
    required this.savePath,
    required this.bpm,
  }) : id = "";

  factory MusicData.fromRow(Map<String, Object?> row) {
    debugPrint(row.toString());
    return MusicData(
      id: row['id'] as String,
      title: row['title'] as String,
      savePath: row['save_path'] as String,
      bpm: row['bpm'] as num,
    );
  }

  MusicData update({String? id, String? title, String? savePath, double? bpm}) {
    return MusicData(
      id: id ?? this.id,
      title: title ?? this.title,
      savePath: savePath ?? this.savePath,
      bpm: bpm ?? this.bpm,
    );
  }

  Map<String, Object?> toRow() {
    return {
      'id': id,
      'title': title,
      'bpm': bpm,
      'save_path': savePath,
    };
  }

  @override
  String toString() {
    return 'Music{id: $id, title: $title}';
  }
}

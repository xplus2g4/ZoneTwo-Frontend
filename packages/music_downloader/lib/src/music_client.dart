import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:id3_codec/id3_decoder.dart';
import 'package:music_downloader/music_downloader.dart';
import 'package:http/http.dart' as http;

class MusicClient {
  MusicClient({
    required this.cacheDirectory,
    http.Client? httpClient,
    this.baseUrl = 'http://localhost:3000',
  }) : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;
  final Directory cacheDirectory;

  Future<Music> downloadByYoutubeLink(String link) async {
    final response = await httpClient.get(Uri.parse(link));

    if (response.statusCode == 200) {
      final contentDisposition = response.headers['content-disposition'];

      String? filename;
      if (contentDisposition != null &&
          contentDisposition.contains('filename=')) {
        // Extract the filename from the header
        final regex = RegExp(r'filename="?(.+)"?');
        final match = regex.firstMatch(contentDisposition);
        if (match != null) {
          filename = match.group(1);
        }
      }

      if (filename != null) {
        final bpm = await _decodeMusicMetadata(response.bodyBytes);
        final filePath = await _writeToFile(filename, response.bodyBytes);
        return Music(title: filename, savePath: filePath, bpm: bpm);
      } else {
        throw ApiError(message: "Filename not found in response");
      }
    } else {
      final results = json.decode(response.body) as Map<String, dynamic>;
      throw ApiError.fromJson(results);
    }
  }

  Future<String> _writeToFile(String filename, List<int> bytes) async {
    final path = '${cacheDirectory.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  Future<double> _decodeMusicMetadata(List<int> bytes) async {
    try {
      final decoder = ID3Decoder(bytes);
      final List metadata = decoder.decodeSync().first.toTagMap()["Frames"];
      final Map tbpmFrame = metadata.firstWhere((f) => f["Frame ID"] == "TBPM");
      return double.parse(tbpmFrame["Content"]["Information"]);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

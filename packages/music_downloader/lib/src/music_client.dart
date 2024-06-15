import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:id3_codec/id3_decoder.dart';
import 'package:music_downloader/music_downloader.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MusicClient {
  MusicClient({Dio? httpClient, this.baseUrl = 'http://10.0.2.2:7771'})
      : httpClient = httpClient ?? Dio();

  final Dio httpClient;
  final String baseUrl;

  Future<MusicInfo> downloadByYoutubeLink(
    String link,
    ProgressCallback progressCallback,
  ) async {
    final response = await httpClient.get<List<int>>(
      "$baseUrl/api/musics/download",
      onReceiveProgress: progressCallback,
      queryParameters: {
        "json_data": jsonEncode({
          "url": link,
        }),
      },
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200 && response.data != null) {
      final contentDisposition = response.headers.value('content-disposition');

      String? rawFilename;
      if (contentDisposition != null &&
          contentDisposition.contains('filename=')) {
        // Extract the filename from the header
        final regex = RegExp(r"filename\*=UTF-8\'\'?(.+)?");
        final match = regex.firstMatch(contentDisposition);
        if (match != null) {
          rawFilename = match.group(1);
        }
      }

      if (rawFilename != null) {
        final filename = Uri.decodeFull(rawFilename);
        final bpm = await _decodeMusicMetadata(response.data!);
        final filePath = await _writeToFile(filename, response.data!);
        return MusicInfo(title: filename, savePath: filePath, bpm: bpm);
      } else {
        throw ApiError(message: "Filename not found in response");
      }
    } else {
      final results =
          json.decode(utf8.decode(response.data!)) as Map<String, dynamic>;
      throw ApiError.fromJson(results);
    }
  }

  Future<String> _writeToFile(String filename, List<int> bytes) async {
    final cacheDirectory = await getApplicationCacheDirectory();
    final path = p.join(cacheDirectory.path, filename);
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

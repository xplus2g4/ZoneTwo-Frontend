import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:download_repository/download_repository.dart';
import 'package:id3tag/id3tag.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/music_metadata.dart';

class DownloadClient {
  DownloadClient({this.saveFolder})
      : httpClient = Dio(BaseOptions(
            baseUrl: const String.fromEnvironment("downloader_api_endpoint",
                defaultValue: "https://h9xmdc8z-7771.asse.devtunnels.ms")));

  final Dio httpClient;
  final String? saveFolder;

  Future<MusicDownloadInfo> downloadByYoutubeLink(
    String link,
    ProgressCallback? progressCallback,
  ) async {
    final response = await httpClient.get<List<int>>(
      "/api/music/download",
      onReceiveProgress: progressCallback,
      queryParameters: {
        "json_data": jsonEncode({
          "url": link,
        }),
      },
      options: Options(
          headers: {'Connection': 'Keep-Alive', 'Accept-Encoding': '*'},
          responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200 && response.data != null) {
      final contentDisposition = response.headers.value('content-disposition');

      String? rawFilename;
      if (contentDisposition != null) {
        // Extract the filename from the header
        final regex = RegExp(r"filename\*=UTF-8\'\'?(.+)?");
        final match = regex.firstMatch(contentDisposition);
        if (match != null) {
          rawFilename = match.group(1);
        }
      }

      if (rawFilename != null) {
        final filename = Uri.decodeFull(rawFilename);
        final filePath = await _writeToFile(filename, response.data!);
        final metadata = await _decodeMusicMetadata(filePath);
        return MusicDownloadInfo(
            title: filename,
            savePath: filePath,
            bpm: metadata.bpm,
            coverImage: metadata.image);
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
    final saveFolder =
        this.saveFolder ?? (await getApplicationCacheDirectory()).path;
    final path = p.join(saveFolder, filename);
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  Future<MusicMetadata> _decodeMusicMetadata(String filePath) async {
    try {
      final parser = ID3TagReader.path(filePath);
      final metadata = parser.readTagSync();
      final num bpm =
          num.parse(metadata.frameWithName("TBPM")!.toDictionary()["value"]);
      final Uint8List image =
          Uint8List.fromList(metadata.pictures.first.imageData);

      return MusicMetadata(image: image, bpm: bpm);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}

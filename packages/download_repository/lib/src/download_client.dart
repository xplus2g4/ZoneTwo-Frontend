import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:id3tag/id3tag.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/music_metadata.dart';

class DownloadClient {
  DownloadClient({this.saveFolder, required String baseUrl})
      : httpClient = Dio(BaseOptions(
          baseUrl: baseUrl,
        ));

  final Dio httpClient;
  final String? saveFolder;

  Future<MusicDownloadInfo> downloadByYoutubeLink(
    String link,
    ProgressCallback? progressCallback,
    ValueChanged<String>? onFilenameCallback,
  ) async {
    final saveFolder =
        this.saveFolder ?? (await getApplicationCacheDirectory()).path;
    String filename = "";
    final cancelToken = CancelToken();
    try {
      await httpClient.download(
        "/api/music/download",
        (Headers headers) {
          final rawFilename = decodeFilename(headers);

          if (rawFilename == null) {
            cancelToken.cancel();
            throw ApiError(message: "Filename not found in response");
          }
          filename = rawFilename;
          onFilenameCallback?.call(filename);

          return p.join(saveFolder, filename);
        },
        cancelToken: cancelToken,
        onReceiveProgress: progressCallback,
        queryParameters: {
          "json_data": jsonEncode({
            "url": link,
          }),
        },
      );
    } catch (e) {
      throw ApiError(message: "api error");
    }

    final filePath = p.join(saveFolder, filename);
    final metadata = await _decodeMusicMetadata(filePath);
    return MusicDownloadInfo(
        title: filename.replaceAll('.mp3', ''),
        savePath: filePath,
        bpm: metadata.bpm,
        coverImage: metadata.image);
  }

  String? decodeFilename(Headers headers) {
    final contentDisposition = headers.value('content-disposition');
    if (contentDisposition == null) {
      return null;
    }
    final regex = RegExp(r"filename\*=UTF-8\'\'?(.+)?");
    final match = regex.firstMatch(contentDisposition);
    if (match == null) {
      return null;
    }
    return Uri.decodeFull(match.group(1)!);
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

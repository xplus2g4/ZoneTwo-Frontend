import 'dart:async';

import 'package:dio/dio.dart';
import 'package:download_repository/download_repository.dart';

class DownloadRepository {
  DownloadRepository({String? saveFolder})
      : _client = DownloadClient(saveFolder: saveFolder);

  final DownloadClient _client;

  Future<MusicDownloadInfo> downloadByYoutubeLink(
    String link,
    ProgressCallback progressCallback,
  ) async {
    return await _client.downloadByYoutubeLink(link, progressCallback);
  }
}

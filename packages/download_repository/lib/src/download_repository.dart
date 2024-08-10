import 'dart:async';

import 'package:dio/dio.dart';
import 'package:download_repository/download_repository.dart';
import 'package:flutter/foundation.dart';

class DownloadRepository {
  DownloadRepository({String? saveFolder})
      : _client = DownloadClient(saveFolder: saveFolder);

  final DownloadClient _client;

  Future<MusicDownloadInfo> downloadByYoutubeLink(String link,
      {ProgressCallback? progressCallback,
      ValueChanged<String>? onFilenameCallback}) async {
    return await _client.downloadByYoutubeLink(
        link, progressCallback, onFilenameCallback);
  }
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:music_downloader/music_downloader.dart';

class MusicRepository {
  const MusicRepository(this.client);

  final MusicClient client;

  Future<MusicInfo> downloadByYoutubeLink(
    String link,
    ProgressCallback progressCallback,
  ) async {
    // Replace this with db logic
    // final cachedResult = cache.get(term);
    // if (cachedResult != null) {
    //   return cachedResult;
    // }
    return await client.downloadByYoutubeLink(link, progressCallback);
  }
}

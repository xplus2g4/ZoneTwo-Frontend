class MusicDownloadInfo {
  const MusicDownloadInfo({
    required this.title,
    required this.savePath,
    required this.bpm,
    required this.coverBase64String,
  });

  final String title;
  final num bpm;
  final String coverBase64String;
  final String savePath;
}

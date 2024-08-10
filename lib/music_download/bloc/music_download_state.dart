part of "music_download_bloc.dart";

class MusicDownloadProgress {
  final String url;
  final double progress;
  final String? error;
  final String? filename;

  MusicDownloadProgress(this.url,
      {this.progress = 0, this.error, this.filename});

  MusicDownloadProgress onError(String error) {
    return MusicDownloadProgress(url,
        progress: progress, error: error, filename: filename);
  }

  MusicDownloadProgress updateFilename(String filename) {
    return MusicDownloadProgress(url,
        progress: progress, error: error, filename: filename);
  }

  MusicDownloadProgress updateProgress(double progress) {
    return MusicDownloadProgress(url,
        progress: progress, error: error, filename: filename);
  }
}

class MusicDownloadState extends Equatable {
  const MusicDownloadState(
      {this.progress = const [], this.linkValidationError = ""});

  final List<MusicDownloadProgress> progress;
  final String linkValidationError;

  @override
  List<Object> get props => [progress, linkValidationError];

  MusicDownloadState copyWith({
    List<MusicDownloadProgress> Function()? progress,
    String Function()? linkValidationError,
  }) {
    return MusicDownloadState(
      progress: progress != null ? progress() : this.progress,
      linkValidationError: linkValidationError != null
          ? linkValidationError()
          : this.linkValidationError,
    );
  }
}

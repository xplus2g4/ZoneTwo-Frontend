part of "music_download_bloc.dart";

sealed class MusicDownloadState extends Equatable {
  const MusicDownloadState();

  @override
  List<Object> get props => [];
}

final class MusicDownloadStateIdle extends MusicDownloadState {}

final class MusicDownloadStateLoading extends MusicDownloadState {
  MusicDownloadStateLoading(double percentage)
      : percentage = percentage.toStringAsFixed(2);

  final String percentage;

  @override
  List<Object> get props => [percentage];

  @override
  String toString() => 'MusicDownloadStateLoading { progress: $percentage%} }';
}

final class MusicDownloadStateSuccess extends MusicDownloadState {
  const MusicDownloadStateSuccess(this.music);

  final MusicEntity music;

  @override
  List<Object> get props => [music];

  @override
  String toString() => 'MusicDownloadStateSuccess { music: ${music.title} }';
}

final class MusicDownloadStateError extends MusicDownloadState {
  const MusicDownloadStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

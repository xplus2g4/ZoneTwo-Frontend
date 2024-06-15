import 'package:music_downloader/music_downloader.dart';
import 'package:equatable/equatable.dart';

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
  const MusicDownloadStateSuccess(this.musicInfo);

  final MusicInfo musicInfo;

  @override
  List<Object> get props => [musicInfo];

  @override
  String toString() =>
      'MusicDownloadStateSuccess { music: ${musicInfo.title} }';
}

final class MusicDownloadStateError extends MusicDownloadState {
  const MusicDownloadStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

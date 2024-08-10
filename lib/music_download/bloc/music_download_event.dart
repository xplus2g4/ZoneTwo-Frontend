part of 'music_download_bloc.dart';

sealed class MusicDownloadEvent extends Equatable {
  const MusicDownloadEvent();
}

final class DownloadClicked extends MusicDownloadEvent {
  const DownloadClicked({required this.link});

  final String link;

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'DownloadClicked { link: $link }';
}

final class LinkSharedEvent extends MusicDownloadEvent {
  const LinkSharedEvent(this.sharedMediaFile);

  final SharedMediaFile sharedMediaFile;

  @override
  List<Object> get props => [sharedMediaFile];

  @override
  String toString() => 'LinkSharedEvent { link: $sharedMediaFile }';
}

final class RetryDownloadEvent extends MusicDownloadEvent {
  const RetryDownloadEvent(this.videoIdentifier);

  final String videoIdentifier;

  @override
  List<Object> get props => [videoIdentifier];

  @override
  String toString() =>
      'RetryDownloadEvent { videoIdentifier: $videoIdentifier }';
}

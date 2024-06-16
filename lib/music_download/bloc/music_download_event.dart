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

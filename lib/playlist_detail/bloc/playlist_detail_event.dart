part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailEvent extends Equatable {
  const PlaylistDetailEvent();

  @override
  List<Object> get props => [];
}

final class PlaylistDetailSubscriptionRequested extends PlaylistDetailEvent {
  const PlaylistDetailSubscriptionRequested(this.playlist);

  final PlaylistEntity playlist;

  @override
  List<Object> get props => [playlist];
}

final class PlaylistNameChanged extends PlaylistDetailEvent {
  const PlaylistNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class PlaylistMusicDeleted extends PlaylistDetailEvent {
  const PlaylistMusicDeleted(this.music);

  final Set<MusicEntity> music;

  @override
  List<Object> get props => [music];
}

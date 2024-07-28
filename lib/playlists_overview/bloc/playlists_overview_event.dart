part of 'playlists_overview_bloc.dart';

sealed class PlaylistsOverviewEvent extends Equatable {
  const PlaylistsOverviewEvent();

  @override
  List<Object> get props => [];
}

final class PlaylistsOverviewSubscriptionRequested
    extends PlaylistsOverviewEvent {
  const PlaylistsOverviewSubscriptionRequested();
}

final class PlaylistsOverviewPlaylistsDeleted extends PlaylistsOverviewEvent {
  const PlaylistsOverviewPlaylistsDeleted(this.playlistIds);

  final Set<String> playlistIds;

  @override
  List<Object> get props => [playlistIds];
}

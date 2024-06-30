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

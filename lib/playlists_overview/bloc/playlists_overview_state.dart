part of 'playlists_overview_bloc.dart';

enum PlaylistsOverviewStatus { initial, loading, success, failure }

final class PlaylistsOverviewState extends Equatable {
  const PlaylistsOverviewState({
    this.status = PlaylistsOverviewStatus.initial,
    this.playlists = const [],
  });

  final PlaylistsOverviewStatus status;
  final List<PlaylistEntity> playlists;

  PlaylistsOverviewState copyWith({
    PlaylistsOverviewStatus Function()? status,
    List<PlaylistEntity> Function()? playlists,
  }) {
    return PlaylistsOverviewState(
      status: status != null ? status() : this.status,
      playlists: playlists != null ? playlists() : this.playlists,
    );
  }

  @override
  List<Object?> get props => [
        status,
        playlists,
      ];
}

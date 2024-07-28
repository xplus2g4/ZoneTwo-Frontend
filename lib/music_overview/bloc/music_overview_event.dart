part of 'music_overview_bloc.dart';

sealed class MusicOverviewEvent extends Equatable {
  const MusicOverviewEvent();

  @override
  List<Object> get props => [];
}

final class MusicOverviewSubscriptionRequested extends MusicOverviewEvent {
  const MusicOverviewSubscriptionRequested();
}

final class MusicOverviewCreatePlaylist extends MusicOverviewEvent {
  const MusicOverviewCreatePlaylist(this.playlistName);

  final String playlistName;

  @override
  List<Object> get props => [playlistName];
}

final class MusicOverviewAddToPlaylist extends MusicOverviewEvent {
  const MusicOverviewAddToPlaylist(this.playlist);

  final PlaylistEntity playlist;

  @override
  List<Object> get props => [playlist];
}

class MusicOverviewDeleteSelected extends MusicOverviewEvent {
  const MusicOverviewDeleteSelected();

  @override
  List<Object> get props => [];
}

final class MusicOverviewEnterSelectionMode extends MusicOverviewEvent {
  const MusicOverviewEnterSelectionMode(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

final class MusicOverviewExitSelectionMode extends MusicOverviewEvent {
  const MusicOverviewExitSelectionMode();

  @override
  List<Object> get props => [];
}

final class MusicOverviewToggleSelectedMusic extends MusicOverviewEvent {
  const MusicOverviewToggleSelectedMusic(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

final class MusicOverviewEditMusic extends MusicOverviewEvent {
  const MusicOverviewEditMusic({required this.music});

  final MusicEntity music;

  @override
  List<Object> get props => [music];
}


// class MusicOverviewFilterChanged extends MusicOverviewEvent {
//   const MusicOverviewFilterChanged(this.filter);

//   final TodosViewFilter filter;

//   @override
//   List<Object> get props => [filter];
// }

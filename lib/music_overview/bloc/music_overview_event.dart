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

final class MusicOverviewEnterSelectionMode extends MusicOverviewEvent {
  const MusicOverviewEnterSelectionMode(this.startIndex);

  final int? startIndex;

  @override
  List<Object> get props => [];
}

final class MusicOverviewExitSelectionMode extends MusicOverviewEvent {
  const MusicOverviewExitSelectionMode();

  @override
  List<Object> get props => [];
}

final class MusicOverviewToggleSelectedMusic extends MusicOverviewEvent {
  const MusicOverviewToggleSelectedMusic(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

// class MusicOverviewFilterChanged extends MusicOverviewEvent {
//   const MusicOverviewFilterChanged(this.filter);

//   final TodosViewFilter filter;

//   @override
//   List<Object> get props => [filter];
// }

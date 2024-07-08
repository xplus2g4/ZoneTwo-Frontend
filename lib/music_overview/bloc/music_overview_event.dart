part of 'music_overview_bloc.dart';

sealed class MusicsOverviewEvent extends Equatable {
  const MusicsOverviewEvent();

  @override
  List<Object> get props => [];
}

final class MusicsOverviewSubscriptionRequested extends MusicsOverviewEvent {
  const MusicsOverviewSubscriptionRequested();
}

final class MusicsOverviewCreatePlaylist extends MusicsOverviewEvent {
  const MusicsOverviewCreatePlaylist(this.playlistName);

  final String playlistName;

  @override
  List<Object> get props => [playlistName];
}

final class MusicOverviewEnterSelectionMode extends MusicsOverviewEvent {
  const MusicOverviewEnterSelectionMode(this.startIndex);

  final int? startIndex;

  @override
  List<Object> get props => [];
}

final class MusicOverviewExitSelectionMode extends MusicsOverviewEvent {
  const MusicOverviewExitSelectionMode();

  @override
  List<Object> get props => [];
}

final class MusicOverviewToggleSelectedMusic extends MusicsOverviewEvent {
  const MusicOverviewToggleSelectedMusic(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

// class MusicsOverviewFilterChanged extends MusicsOverviewEvent {
//   const MusicsOverviewFilterChanged(this.filter);

//   final TodosViewFilter filter;

//   @override
//   List<Object> get props => [filter];
// }

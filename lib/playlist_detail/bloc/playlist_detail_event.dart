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

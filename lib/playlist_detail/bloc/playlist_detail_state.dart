part of 'playlist_detail_bloc.dart';

final class PlaylistDetailState extends Equatable {
  const PlaylistDetailState(this.playlist, {this.music = const []});

  final PlaylistEntity playlist;
  final List<MusicEntity> music;

  PlaylistDetailState copyWith({
    PlaylistEntity Function()? playlist,
    List<MusicEntity> Function()? music,
  }) {
    return PlaylistDetailState(
      playlist != null ? playlist() : this.playlist,
      music: music != null ? music() : this.music,
    );
  }

  @override
  List<Object> get props => [playlist, music];
}

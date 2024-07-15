part of 'playlist_detail_bloc.dart';

final class PlaylistDetailState extends Equatable {
  const PlaylistDetailState({this.music = const []});

  final List<MusicEntity> music;

  PlaylistDetailState copyWith({
    List<MusicEntity> Function()? music,
  }) {
    return PlaylistDetailState(
      music: music != null ? music() : this.music,
    );
  }

  @override
  List<Object> get props => [music];
}

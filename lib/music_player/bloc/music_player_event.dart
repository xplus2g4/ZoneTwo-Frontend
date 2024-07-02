part of 'music_player_bloc.dart';

sealed class MusicPlayerEvent extends Equatable {
  const MusicPlayerEvent();

  @override
  List<Object> get props => [];
}

final class MusicPlayerQueueMusics extends MusicPlayerEvent {
  const MusicPlayerQueueMusics(this.musics);

  final List<MusicEntity> musics;

  @override
  List<Object> get props => [musics];
}

final class MusicPlayerInsertNext extends MusicPlayerEvent {
  const MusicPlayerInsertNext(this.music);

  final MusicEntity music;

  @override
  List<Object> get props => [music];
}

final class MusicPlayerPause extends MusicPlayerEvent {
  const MusicPlayerPause();
}

final class MusicPlayerResume extends MusicPlayerEvent {
  const MusicPlayerResume();
}

final class MusicPlayerSetBpm extends MusicPlayerEvent {
  const MusicPlayerSetBpm(this.bpm);

  final num bpm;
}

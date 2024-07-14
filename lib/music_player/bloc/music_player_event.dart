part of 'music_player_bloc.dart';

sealed class MusicPlayerEvent extends Equatable {
  const MusicPlayerEvent();

  @override
  List<Object> get props => [];
}

final class MusicPlayerQueueMusic extends MusicPlayerEvent {
  const MusicPlayerQueueMusic(this.music);

  final List<MusicEntity> music;

  @override
  List<Object> get props => [music];
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

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

final class MusicPlayerPositionChanged extends MusicPlayerEvent {
  const MusicPlayerPositionChanged(this.position);

  final Duration position;

  @override
  List<Object> get props => [position];
}

final class MusicPlayerDurationChanged extends MusicPlayerEvent {
  const MusicPlayerDurationChanged(this.duration);

  final Duration duration;

  @override
  List<Object> get props => [duration];
}

final class MusicPlayerPause extends MusicPlayerEvent {
  const MusicPlayerPause();
}

final class MusicPlayerResume extends MusicPlayerEvent {
  const MusicPlayerResume();
}

final class MusicPlayerSeek extends MusicPlayerEvent {
  const MusicPlayerSeek(this.position);

  final Duration position;
}

final class MusicPlayerSetBpm extends MusicPlayerEvent {
  const MusicPlayerSetBpm(this.bpm);

  final num bpm;
}

final class MusicPlayerLoadMusic extends MusicPlayerEvent {
  const MusicPlayerLoadMusic(this.music);

  final MusicEntity music;
}

final class MusicPlayerEnterFullscreen extends MusicPlayerEvent {
  const MusicPlayerEnterFullscreen();
}

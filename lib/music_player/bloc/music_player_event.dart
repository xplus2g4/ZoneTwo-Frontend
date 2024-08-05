part of 'music_player_bloc.dart';

sealed class MusicPlayerEvent extends Equatable {
  const MusicPlayerEvent();

  @override
  List<Object> get props => [];
}


final class MusicPlayerQueueMusic extends MusicPlayerEvent {
  const MusicPlayerQueueMusic(this.music, this.playlistName,
      {this.playIndex, this.playMusicEntity})
      : assert(playIndex == null || playMusicEntity == null);

  final List<MusicEntity> music;
  final String playlistName;
  final int? playIndex;
  final MusicEntity? playMusicEntity;

  @override
  List<Object> get props => [music];
}

final class MusicPlayerQueueAllMusic extends MusicPlayerEvent {
  const MusicPlayerQueueAllMusic({this.playIndex, this.playMusicEntity})
      : assert(playIndex == null || playMusicEntity == null);

  final int? playIndex;
  final MusicEntity? playMusicEntity;
}

final class MusicPlayerQueuePlaylistMusic extends MusicPlayerEvent {
  const MusicPlayerQueuePlaylistMusic(this.playlist,
      {this.playIndex, this.playMusicEntity})
      : assert(playIndex == null || playMusicEntity == null);

  final PlaylistEntity playlist;
  final int? playIndex;
  final MusicEntity? playMusicEntity;

  @override
  List<Object> get props => [playlist];
}

final class MusicPlayerPlayThisMusic extends MusicPlayerEvent {
  const MusicPlayerPlayThisMusic(this.music);

  final MusicEntity music;

  @override
  List<Object> get props => [music];

}

final class MusicPlayerPlayAtIndex extends MusicPlayerEvent {
  const MusicPlayerPlayAtIndex(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

final class MusicPlayerPlayNext extends MusicPlayerEvent {
  const MusicPlayerPlayNext();
}

final class MusicPlayerPlayPrevious extends MusicPlayerEvent {
  const MusicPlayerPlayPrevious();
}

final class MusicPlayerToggleShuffle extends MusicPlayerEvent {
  const MusicPlayerToggleShuffle();
}

final class MusicPlayerToggleLoop extends MusicPlayerEvent {
  const MusicPlayerToggleLoop();
}

final class MusicPlayerToggleBPMSync extends MusicPlayerEvent {
  const MusicPlayerToggleBPMSync();
}

final class MusicPlayerLoop extends MusicPlayerEvent {
  const MusicPlayerLoop();
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

final class MusicPlayerStop extends MusicPlayerEvent {
  const MusicPlayerStop();
}

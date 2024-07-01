part of 'music_player_bloc.dart';

enum MusicPlayerStatus { idle, playing, paused, insertNext }

final class MusicPlayerState extends Equatable {
  const MusicPlayerState(
      {this.status = MusicPlayerStatus.idle,
      this.musicQueue = const [],
      this.currentIndex = -1,
      this.bpm = 150});

  final MusicPlayerStatus status;
  final int currentIndex;
  final List<MusicEntity> musicQueue;
  final num bpm;

  MusicPlayerState copyWith({
    MusicPlayerStatus Function()? status,
    int Function()? currentIndex,
    List<MusicEntity> Function()? musicQueue,
    num Function()? bpm,
  }) {
    return MusicPlayerState(
      status: status != null ? status() : this.status,
      currentIndex: currentIndex != null ? currentIndex() : this.currentIndex,
      musicQueue: musicQueue != null ? musicQueue() : this.musicQueue,
      bpm: bpm != null ? bpm() : this.bpm,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentIndex,
        musicQueue,
        bpm,
      ];
}

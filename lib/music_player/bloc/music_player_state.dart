part of 'music_player_bloc.dart';


final class MusicPlayerState extends Equatable {
  const MusicPlayerState(
      {this.musicQueue = const [],
      this.currentIndex = -1,
      this.bpm = 160,
      this.audioPlayerState = PlayerState.stopped,
      this.audioPlayerPosition = Duration.zero,
      this.audioPlayerDuration = Duration.zero, 
      required this.audioPlayer});

  final int currentIndex;
  final List<MusicEntity> musicQueue;
  final num bpm;
  final PlayerState audioPlayerState;
  final Duration audioPlayerPosition;
  final Duration audioPlayerDuration;
  final AudioPlayer audioPlayer;


  MusicPlayerState copyWith({
    int Function()? currentIndex,
    List<MusicEntity> Function()? musicQueue,
    num Function()? bpm,
    PlayerState Function()? audioPlayerState,
    Duration Function()? audioPlayerPosition,
    Duration Function()? audioPlayerDuration,
    AudioPlayer Function()? audioPlayer,
  }) {
    return MusicPlayerState(
      musicQueue: musicQueue != null ? musicQueue() : this.musicQueue,
      currentIndex: currentIndex != null ? currentIndex() : this.currentIndex,
      bpm: bpm != null ? bpm() : this.bpm,
      audioPlayerState:
          audioPlayerState != null ? audioPlayerState() : this.audioPlayerState,
      audioPlayerPosition: audioPlayerPosition != null
          ? audioPlayerPosition()
          : this.audioPlayerPosition,
      audioPlayerDuration: audioPlayerDuration != null
          ? audioPlayerDuration()
          : this.audioPlayerDuration,
      audioPlayer: audioPlayer != null ? audioPlayer() : this.audioPlayer,
    );
  }

  @override
  List<Object?> get props => [
        musicQueue,
        currentIndex,
        bpm,
        audioPlayerState,
        audioPlayerPosition,
        audioPlayerDuration,
        audioPlayer,
      ];
}

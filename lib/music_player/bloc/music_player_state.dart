part of 'music_player_bloc.dart';

final class MusicPlayerState extends Equatable {
  const MusicPlayerState(
      {this.playlistQueue = const [],
      this.shuffledQueue = const [],
      this.playlistIndex = -1,
      this.shuffledIndex = -1,
      this.playlistName = "All Music",
      this.bpm = 150,
      this.isShuffle = false,
      this.isLoop = false,
      this.isBPMSync = true,
      this.audioPlayerState = PlayerState.stopped,
      this.audioPlayerPosition = Duration.zero,
      this.audioPlayerDuration = Duration.zero,
      required this.audioPlayer});

  final List<MusicEntity> playlistQueue;
  final List<MusicEntity> shuffledQueue;
  final int playlistIndex;
  final int shuffledIndex;
  final num bpm;
  final String playlistName;
  final bool isShuffle;
  final bool isLoop;
  final bool isBPMSync;
  final PlayerState audioPlayerState;
  final Duration audioPlayerPosition;
  final Duration audioPlayerDuration;
  final AudioPlayer audioPlayer;

  MusicPlayerState copyWith({
    List<MusicEntity> Function()? playlistQueue,
    List<MusicEntity> Function()? shuffledQueue,
    int Function()? playlistIndex,
    int Function()? shuffledIndex,
    String Function()? playlistName,
    num Function()? bpm,
    bool Function()? isShuffle,
    bool Function()? isLoop,
    bool Function()? isBPMSync,
    PlayerState Function()? audioPlayerState,
    Duration Function()? audioPlayerPosition,
    Duration Function()? audioPlayerDuration,
    AudioPlayer Function()? audioPlayer,
  }) {
    return MusicPlayerState(
      playlistQueue:
          playlistQueue != null ? playlistQueue() : this.playlistQueue,
      shuffledQueue:
          shuffledQueue != null ? shuffledQueue() : this.shuffledQueue,
      playlistIndex:
          playlistIndex != null ? playlistIndex() : this.playlistIndex,
      shuffledIndex:
          shuffledIndex != null ? shuffledIndex() : this.shuffledIndex,
      playlistName: playlistName != null ? playlistName() : this.playlistName,
      bpm: bpm != null ? bpm() : this.bpm,
      isShuffle: isShuffle != null ? isShuffle() : this.isShuffle,
      isLoop: isLoop != null ? isLoop() : this.isLoop,
      isBPMSync: isBPMSync != null ? isBPMSync() : this.isBPMSync,
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
        playlistQueue,
        shuffledQueue,
        playlistIndex,
        shuffledIndex,
        playlistName,
        bpm,
        isShuffle,
        isLoop,
        isBPMSync,
        audioPlayerState,
        audioPlayerPosition,
        audioPlayerDuration,
        audioPlayer,
      ];
}

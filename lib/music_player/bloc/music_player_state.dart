part of 'music_player_bloc.dart';


final class MusicPlayerState extends Equatable {
  const MusicPlayerState(
      {this.musicQueue = const [],
      this.currentIndex = -1,
      this.bpm = 200,
      required this.audioPlayer});

  final int currentIndex;
  final List<MusicEntity> musicQueue;
  final num bpm;
  final AudioPlayer audioPlayer;

  MusicPlayerState copyWith({
    int Function()? currentIndex,
    List<MusicEntity> Function()? musicQueue,
    num Function()? bpm,
    AudioPlayer Function()? audioPlayer,
  }) {
    return MusicPlayerState(
      musicQueue: musicQueue != null ? musicQueue() : this.musicQueue,
      currentIndex: currentIndex != null ? currentIndex() : this.currentIndex,
      bpm: bpm != null ? bpm() : this.bpm,
      audioPlayer: audioPlayer != null ? audioPlayer() : this.audioPlayer,
    );
  }

  @override
  List<Object?> get props => [
        musicQueue,
        currentIndex,
        bpm,
        audioPlayer,
      ];
}

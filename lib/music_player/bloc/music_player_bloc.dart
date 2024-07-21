import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

part 'music_player_event.dart';
part 'music_player_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class MusicPlayerBloc extends HydratedBloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc() : super(MusicPlayerState(audioPlayer: AudioPlayer())) {
    on<MusicPlayerInsertNext>(_onInsertNext);
    on<MusicPlayerPositionChanged>(_onPositionChanged);
    on<MusicPlayerDurationChanged>(_onDurationChanged);
    on<MusicPlayerPause>(_onPause);
    on<MusicPlayerResume>(_onResume);
    on<MusicPlayerSeek>(_onSeek);
    on<MusicPlayerSetBpm>(_onSetBpm, transformer: debounce(_duration));
    on<MusicPlayerEnterFullscreen>(_onEnterFullscreen);
  }

  @override
  MusicPlayerState fromJson(Map<String, dynamic> json) {
    return state.copyWith(
      bpm: () => json['bpm'],
    );
  }

  @override
  Map<String, dynamic> toJson(MusicPlayerState state) {
    return {
      'bpm': state.bpm,
    };
  }

  Future<void> _onInsertNext(
    MusicPlayerInsertNext event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final newQueue = List<MusicEntity>.from(state.musicQueue);
    if (state.currentIndex == state.musicQueue.length - 1) {
      newQueue.add(event.music);
    } else {
      newQueue.insert(state.currentIndex + 1, event.music);
    }
    final newIndex = state.currentIndex + 1;

    if (newIndex != -1) {
      final currMusic = newQueue[newIndex];
      if (state.audioPlayer.state == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(currMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / currMusic.bpm);
    }

    emit(state.copyWith(
      musicQueue: () => newQueue,
      currentIndex: () => newIndex,
      audioPlayerState: () => PlayerState.playing,
    ));
  }

  Future<void> _onPositionChanged(
    MusicPlayerPositionChanged event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(audioPlayerPosition: () => event.position));
  }

  Future<void> _onDurationChanged(
    MusicPlayerDurationChanged event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(audioPlayerDuration: () => event.duration));
  }

  Future<void> _onPause(
    MusicPlayerPause event,
    Emitter<MusicPlayerState> emit,
  ) async {
    state.audioPlayer.pause();
    emit(state.copyWith(audioPlayerState: () => PlayerState.paused));
  }

  Future<void> _onResume(
    MusicPlayerResume event,
    Emitter<MusicPlayerState> emit,
  ) async {
    state.audioPlayer.resume();
    emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
  }

  Future<void> _onSetBpm(
    MusicPlayerSetBpm event,
    Emitter<MusicPlayerState> emit,
  ) async {
    state.audioPlayer
        .setPlaybackRate(event.bpm / state.musicQueue[state.currentIndex].bpm);
    emit(state.copyWith(bpm: () => event.bpm));
  }

  Future<void> _onEnterFullscreen(
    MusicPlayerEnterFullscreen event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(
      audioPlayer: () => state.audioPlayer,
    ));
  }

  Future<void> _onSeek(
    MusicPlayerSeek event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(audioPlayerPosition: () => event.position));
    state.audioPlayer.seek(event.position);
  }
}

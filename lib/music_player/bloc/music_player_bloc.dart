import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

part 'music_player_event.dart';
part 'music_player_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc() : super(const MusicPlayerState()) {
    on<MusicPlayerInsertNext>(_onInsertNext);
    on<MusicPlayerPause>(_onPause);
    on<MusicPlayerResume>(_onResume);
    on<MusicPlayerSetBpm>(_onSetBpm, transformer: debounce(_duration));
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
    emit(state.copyWith(
        status: () => MusicPlayerStatus.insertNext,
        musicQueue: () => newQueue,
        currentIndex: () => newIndex));
  }

  Future<void> _onPause(
    MusicPlayerPause event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(status: () => MusicPlayerStatus.paused));
  }

  Future<void> _onResume(
    MusicPlayerResume event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(status: () => MusicPlayerStatus.playing));
  }

  Future<void> _onSetBpm(
    MusicPlayerSetBpm event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(bpm: () => event.bpm));
  }
}

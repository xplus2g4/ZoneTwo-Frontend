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
    on<MusicPlayerQueueMusic>(_onQueueMusic);
    on<MusicPlayerToggleShuffle>(_onToggleShuffle);
    on<MusicPlayerToggleLoop>(_onToggleLoop);
    on<MusicPlayerLoop>(_onLoop);
    on<MusicPlayerPlayNext>(_onPlayNext);
    on<MusicPlayerPlayPrevious>(_onPlayPrevious);
    on<MusicPlayerPlayThisMusic>(_onPlayThisMusic);
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

  //Populate playlist queue. In general, all Music Player Events cascade from
  //this event, thus it is synchronous
  void _onQueueMusic(
    MusicPlayerQueueMusic event,
    Emitter<MusicPlayerState> emit,
  ) {
    final newPlaylistQueue = List<MusicEntity>.from(event.music);
    final newShuffledQueue = List<MusicEntity>.from(event.music);
    newShuffledQueue.shuffle();
    emit(state.copyWith(
      playlistQueue: () => newPlaylistQueue,
      shuffledQueue: () => newShuffledQueue,
    ));
  }

  //Toggle shuffle mode. Shuffle the playlist on every toggle. Same logic as
  //above.
  void _onToggleShuffle(
    MusicPlayerToggleShuffle event,
    Emitter<MusicPlayerState> emit,
  ) {
    if (_currentMusic != null) {
      final currentMusic = _currentMusic!;
      state.audioPlayer.setPlaybackRate(state.bpm / _currentMusic!.bpm);
      final newShuffledQueue = List<MusicEntity>.from(state.playlistQueue);
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        shuffledQueue: () => newShuffledQueue,
        shuffledIndex: () => newShuffledQueue.indexOf(currentMusic),
        playlistIndex: () => state.playlistQueue.indexOf(currentMusic),
        isShuffle: () => !state.isShuffle,
      ));
    } else {
      final newShuffledQueue = List<MusicEntity>.from(state.playlistQueue);
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        shuffledQueue: () => newShuffledQueue,
        shuffledIndex: () => -1,
        isShuffle: () => !state.isShuffle,
      ));
    }
  }

  Future<void> _onToggleLoop(
    MusicPlayerToggleLoop event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(isLoop: () => !state.isLoop));
  }

  //Play the next song. This event ignores loop. For loop behaviour, use
  //_onLoop. This avoids deep nested conditionals.
  Future<void> _onPlayNext(
    MusicPlayerPlayNext event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (!state.isShuffle) {
      final index = state.playlistIndex >= state.playlistQueue.length - 1
          ? 0
          : state.playlistIndex + 1;
      final nextMusic = state.playlistQueue[index];
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(nextMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / nextMusic.bpm);
      emit(state.copyWith(
        playlistIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      final int index;
      List<MusicEntity> newShuffledQueue =
          List<MusicEntity>.from(state.shuffledQueue);
      //only for next song: when you start over, reshuffle the queue in a way
      //that the first song is not the same as the last song
      if (state.shuffledIndex >= state.shuffledQueue.length - 1) {
        index = 0;
        newShuffledQueue = List<MusicEntity>.from(state.shuffledQueue);
        newShuffledQueue.shuffle();
        while (newShuffledQueue[0].id ==
            state.shuffledQueue[state.shuffledQueue.length - 1].id) {
          newShuffledQueue.shuffle();
        }
      } else {
        index = state.shuffledIndex + 1;
        newShuffledQueue = List<MusicEntity>.from(state.shuffledQueue);
      }
      final nextMusic = newShuffledQueue[index];
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(nextMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / nextMusic.bpm);
      emit(state.copyWith(
        shuffledIndex: () => index,
        shuffledQueue: () => newShuffledQueue,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
  }

  Future<void> _onPlayPrevious(
    MusicPlayerPlayPrevious event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final int index;
    if (!state.isShuffle) {
      final index = state.playlistIndex <= 0
          ? state.playlistQueue.length - 1
          : state.playlistIndex - 1;
      final previousMusic = state.playlistQueue[index];
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(previousMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / previousMusic.bpm);
      emit(state.copyWith(
        playlistIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      index = state.shuffledIndex <= 0
          ? state.shuffledQueue.length - 1
          : state.shuffledIndex - 1;
      final previousMusic = state.shuffledQueue[index];
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(previousMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / previousMusic.bpm);
      emit(state.copyWith(
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
  }

  //Play the song in the event param
  Future<void> _onPlayThisMusic(
    MusicPlayerPlayThisMusic event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (!state.isShuffle) {
      if (_currentMusic != null && _currentMusic!.id == event.music.id) {
        state.audioPlayer.resume();
        emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
        return;
      }
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(event.music.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / event.music.bpm);
      final index = state.playlistQueue.indexOf(event.music);
      emit(state.copyWith(
        playlistIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      if (_currentMusic != null && _currentMusic!.id == event.music.id) {
        state.audioPlayer.resume();
        emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
        return;
      }
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(event.music.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / event.music.bpm);
      final index = state.shuffledQueue.indexOf(event.music);
      emit(state.copyWith(
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
  }

  Future<void> _onPlayAtIndex(
    MusicPlayerPlayAtIndex event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (!state.isShuffle) {
      if (event.index == state.playlistIndex) {
        state.audioPlayer.resume();
        emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
        return;
      }
      final index = event.index >= state.playlistQueue.length ? 0 : event.index;
      final currentMusic = _currentMusic!;
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(currentMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / currentMusic.bpm);
      emit(state.copyWith(
        playlistIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      if (event.index == state.shuffledIndex) {
        state.audioPlayer.resume();
        emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
        return;
      }
      final index = event.index >= state.shuffledQueue.length ? 0 : event.index;
      final currentMusic = _currentMusic!;
      if (state.audioPlayerState == PlayerState.playing) {
        state.audioPlayer.stop();
      }
      state.audioPlayer
          .setSourceDeviceFile(currentMusic.savePath)
          .then((_) => state.audioPlayer.resume());
      state.audioPlayer.setPlaybackRate(state.bpm / currentMusic.bpm);
      emit(state.copyWith(
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
  }

  Future<void> _onLoop(
    MusicPlayerLoop event,
    Emitter<MusicPlayerState> emit,
  ) async {
    final currentMusic = _currentMusic!;
    if (state.audioPlayerState == PlayerState.playing) {
      state.audioPlayer.stop();
    }
    state.audioPlayer
        .setSourceDeviceFile(currentMusic.savePath)
        .then((_) => state.audioPlayer.resume());
    state.audioPlayer.setPlaybackRate(state.bpm / currentMusic.bpm);
    emit(state.copyWith(
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
    state.audioPlayer.setPlaybackRate(
        event.bpm / state.playlistQueue[state.playlistIndex].bpm);
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
    await state.audioPlayer.seek(event.position);
    emit(state.copyWith(audioPlayerPosition: () => event.position));
  }

  Future<void> _onStop(
    MusicPlayerStop event,
    Emitter<MusicPlayerState> emit,
  ) async {
    state.audioPlayer.stop();
    emit(state.copyWith(
      playlistQueue: () => [],
      shuffledQueue: () => [],
      playlistIndex: () => -1,
      shuffledIndex: () => -1,
      audioPlayerState: () => PlayerState.stopped,
      audioPlayerPosition: () => Duration.zero,
      audioPlayerDuration: () => Duration.zero,
    ));
  }

  //Helpers
  MusicEntity? get _currentMusic => !state.isShuffle
      ? state.playlistIndex != -1
          ? state.playlistQueue[state.playlistIndex]
          : null
      : state.shuffledIndex != -1
          ? state.shuffledQueue[state.shuffledIndex]
          : null;
}

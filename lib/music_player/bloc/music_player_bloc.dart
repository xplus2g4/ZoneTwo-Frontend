import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/playlists_overview/entities/playlist_entity.dart';

part 'music_player_event.dart';
part 'music_player_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

//in general we rely on state to be our source of truth, because the audio
//player has a mind of its own.
//always update state first before doing anything with the audio
class MusicPlayerBloc extends HydratedBloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc({
    required MusicRepository musicRepository,
    required PlaylistRepository playlistRepository,
  })  : _musicRepository = musicRepository,
        _playlistRepository = playlistRepository,
        super(MusicPlayerState(audioPlayer: AudioPlayer())) {
    on<MusicPlayerQueueMusic>(_onQueueMusic);
    on<MusicPlayerQueueAllMusic>(_onQueueAllMusic);
    on<MusicPlayerQueuePlaylistMusic>(_onQueuePlaylistMusic);
    on<MusicPlayerToggleShuffle>(_onToggleShuffle);
    on<MusicPlayerToggleLoop>(_onToggleLoop);
    on<MusicPlayerToggleBPMSync>(_onToggleBPMSync);
    on<MusicPlayerLoop>(_onLoop);
    on<MusicPlayerPlayNext>(_onPlayNext);
    on<MusicPlayerPlayPrevious>(_onPlayPrevious);
    on<MusicPlayerPlayThisMusic>(_onPlayThisMusic);
    on<MusicPlayerPlayAtIndex>(_onPlayAtIndex);
    on<MusicPlayerPositionChanged>(_onPositionChanged);
    on<MusicPlayerDurationChanged>(_onDurationChanged);
    on<MusicPlayerPause>(_onPause);
    on<MusicPlayerResume>(_onResume);
    on<MusicPlayerSeek>(_onSeek);
    on<MusicPlayerSetBpm>(_onSetBpm, transformer: debounce(_duration));
    on<MusicPlayerStop>(_onStop);
  }

  final MusicRepository _musicRepository;
  final PlaylistRepository _playlistRepository;

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
      playlistName: () => event.playlistName,
    ));
    if (event.playIndex != null) {
      add(MusicPlayerPlayAtIndex(event.playIndex!));
    }
    if (event.playMusicEntity != null) {
      add(MusicPlayerPlayThisMusic(event.playMusicEntity!));
    }
  }

  Future<void> _onQueueAllMusic(
    MusicPlayerQueueAllMusic event,
    Emitter<MusicPlayerState> emit,
  ) async {
    await _musicRepository.getAllMusicData();
    await _musicRepository.getMusic().first.then((music) {
      final newPlaylistQueue = music.map(MusicEntity.fromData).toList();
      final newShuffledQueue = List<MusicEntity>.from(newPlaylistQueue);
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        playlistQueue: () => newPlaylistQueue,
        shuffledQueue: () => newShuffledQueue,
        playlistName: () => 'All Music',
      ));
      if (event.playIndex != null) {
        add(MusicPlayerPlayAtIndex(event.playIndex!));
      }
      if (event.playMusicEntity != null) {
        add(MusicPlayerPlayThisMusic(event.playMusicEntity!));
      }
    });
  }

  Future<void> _onQueuePlaylistMusic(
    MusicPlayerQueuePlaylistMusic event,
    Emitter<MusicPlayerState> emit,
  ) async {
    await _playlistRepository.getPlaylistWithMusic(event.playlist.toData());
    await _playlistRepository
        .getPlaylistWithMusicStream()
        .first
        .then((playlist) {
      final newPlaylistQueue =
          playlist.music.map(MusicEntity.fromData).toList();
      final newShuffledQueue =
          List<MusicEntity>.from(playlist.music.map(MusicEntity.fromData));
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        playlistQueue: () => newPlaylistQueue,
        shuffledQueue: () => newShuffledQueue,
      ));
      if (event.playIndex != null) {
        add(MusicPlayerPlayAtIndex(event.playIndex!));
      }
      if (event.playMusicEntity != null) {
        add(MusicPlayerPlayThisMusic(event.playMusicEntity!));
      }

    });
  }

  Future<void> _onToggleShuffle(
    MusicPlayerToggleShuffle event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (_currentMusic != null) {
      final currentMusic = _currentMusic!;
      final newShuffledQueue = List<MusicEntity>.from(state.playlistQueue);
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        shuffledQueue: () => newShuffledQueue,
        shuffledIndex: () =>
            newShuffledQueue.indexWhere((music) => music.id == currentMusic.id),
        playlistIndex: () => state.playlistQueue
            .indexWhere((music) => music.id == currentMusic.id),
        isShuffle: () => !state.isShuffle,
      ));
    } else {
      final newShuffledQueue = List<MusicEntity>.from(state.playlistQueue);
      newShuffledQueue.shuffle();
      emit(state.copyWith(
        shuffledQueue: () => newShuffledQueue,
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

  Future<void> _onToggleBPMSync(
    MusicPlayerToggleBPMSync event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(isBPMSync: () => !state.isBPMSync));
    state.audioPlayer.setPlaybackRate(_playbackRate);
  }

  //Play the next song. This event ignores loop. For loop behaviour, use
  //_onLoop. This avoids deep nested conditionals.
  Future<void> _onPlayNext(
    MusicPlayerPlayNext event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.playlistQueue.isEmpty) return;
    if (!state.isShuffle) {
      final index = state.playlistIndex >= state.playlistQueue.length - 1
          ? 0
          : state.playlistIndex + 1;
      emit(state.copyWith(
        playlistIndex: () => index,
        shuffledIndex: () => state.shuffledQueue
            .indexWhere((music) => music.id == state.playlistQueue[index].id),
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
        newShuffledQueue.shuffle();
        while (newShuffledQueue[0].id ==
            state.shuffledQueue[state.shuffledQueue.length - 1].id) {
          newShuffledQueue.shuffle();
        }
      } else {
        index = state.shuffledIndex + 1;
      }
      emit(state.copyWith(
        playlistIndex: () => state.playlistQueue
            .indexWhere((music) => music.id == newShuffledQueue[index].id),
        shuffledIndex: () => index,
        shuffledQueue: () => newShuffledQueue,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
    _play();
  }

  Future<void> _onPlayPrevious(
    MusicPlayerPlayPrevious event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.playlistQueue.isEmpty) return;
    final int index;
    if (!state.isShuffle) {
      final index = state.playlistIndex <= 0
          ? state.playlistQueue.length - 1
          : state.playlistIndex - 1;
      emit(state.copyWith(
        playlistIndex: () => index,
        shuffledIndex: () => state.shuffledQueue
            .indexWhere((music) => music.id == state.playlistQueue[index].id),
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      index = state.shuffledIndex <= 0
          ? state.shuffledQueue.length - 1
          : state.shuffledIndex - 1;
      emit(state.copyWith(
        playlistIndex: () => state.playlistQueue
            .indexWhere((music) => music.id == state.shuffledQueue[index].id),
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
    _play();
  }

  //Play the song in the event param
  Future<void> _onPlayThisMusic(
    MusicPlayerPlayThisMusic event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.playlistQueue.isEmpty) return;
    if (!state.isShuffle) {
      final index = state.playlistQueue.indexOf(event.music);
      emit(state.copyWith(
        playlistIndex: () => index,
        shuffledIndex: () => state.shuffledQueue
            .indexWhere((music) => music.id == event.music.id),
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      final index = state.shuffledQueue.indexOf(event.music);
      emit(state.copyWith(
        playlistIndex: () => state.playlistQueue
            .indexWhere((music) => music.id == event.music.id),
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
    _play();
  }

  Future<void> _onPlayAtIndex(
    MusicPlayerPlayAtIndex event,
    Emitter<MusicPlayerState> emit,
  ) async {
    if (state.playlistQueue.isEmpty) return;
    if (!state.isShuffle) {
      final index = event.index >= state.playlistQueue.length ? 0 : event.index;
      emit(state.copyWith(
        playlistIndex: () => index,
        shuffledIndex: () => state.shuffledQueue
            .indexWhere((music) => music.id == state.playlistQueue[index].id),
        audioPlayerState: () => PlayerState.playing,
      ));
    } else {
      final index = event.index >= state.shuffledQueue.length ? 0 : event.index;
      emit(state.copyWith(
        playlistIndex: () => state.playlistQueue
            .indexWhere((music) => music.id == state.shuffledQueue[index].id),
        shuffledIndex: () => index,
        audioPlayerState: () => PlayerState.playing,
      ));
    }
    _play();
  }

  Future<void> _onLoop(
    MusicPlayerLoop event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(
      audioPlayerState: () => PlayerState.playing,
    ));
    _play();
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
    emit(state.copyWith(audioPlayerState: () => PlayerState.paused));
    state.audioPlayer.pause();
  }

  Future<void> _onResume(
    MusicPlayerResume event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(audioPlayerState: () => PlayerState.playing));
    state.audioPlayer.resume();
  }

  Future<void> _onSetBpm(
    MusicPlayerSetBpm event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(bpm: () => event.bpm));
    state.audioPlayer.setPlaybackRate(_playbackRate);
  }

  Future<void> _onSeek(
    MusicPlayerSeek event,
    Emitter<MusicPlayerState> emit,
  ) async {
    emit(state.copyWith(audioPlayerPosition: () => event.position));
    await state.audioPlayer.seek(event.position);
  }

  void _onStop(
    MusicPlayerStop event,
    Emitter<MusicPlayerState> emit,
  ) {
    emit(state.copyWith(
      playlistQueue: () => [],
      shuffledQueue: () => [],
      playlistIndex: () => -1,
      shuffledIndex: () => -1,
      playlistName: () => '',
      audioPlayerState: () => PlayerState.stopped,
      audioPlayerPosition: () => Duration.zero,
      audioPlayerDuration: () => Duration.zero,
    ));
    state.audioPlayer.stop();
  }

  //Helpers
  //ALWAYS UPDATE STATE FIRST BEFORE USING THIS GETTER
  MusicEntity? get _currentMusic => !state.isShuffle
      ? state.playlistIndex >= 0 &&
              state.playlistIndex < state.playlistQueue.length
          ? state.playlistQueue[state.playlistIndex]
          : null
      : state.shuffledIndex >= 0 &&
              state.shuffledIndex < state.shuffledQueue.length
          ? state.shuffledQueue[state.shuffledIndex]
          : null;
  
  //ALWAYS UPDATE STATE FIRST BEFORE USING THIS GETTER
  double get _playbackRate =>
      state.isBPMSync
      ? state.bpm / (_currentMusic == null ? state.bpm : _currentMusic!.bpm)
      : 1;

  //ALWAYS UPDATE STATE FIRST BEFORE DOING THIS
  void _play() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_currentMusic == null) return;
    final currentMusic = _currentMusic!;
    if (state.audioPlayerState == PlayerState.playing) {
      state.audioPlayer.stop();
    }
    state.audioPlayer
        .setSourceDeviceFile(currentMusic.savePath)
        .then((_) => state.audioPlayer.resume());
    state.audioPlayer.setPlaybackRate(_playbackRate);
  }
}

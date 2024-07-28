import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

part 'music_overview_event.dart';
part 'music_overview_state.dart';

class MusicOverviewBloc extends Bloc<MusicOverviewEvent, MusicOverviewState> {
  MusicOverviewBloc({
    required MusicRepository musicRepository,
    required PlaylistRepository playlistRepository,
  })  : _musicRepository = musicRepository,
        _playlistRepository = playlistRepository,
        super(const MusicOverviewState()) {
    on<MusicOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<MusicOverviewCreatePlaylist>(_onCreatePlaylists);
    on<MusicOverviewEnterSelectionMode>(_onEnterSelectionMode);
    on<MusicOverviewExitSelectionMode>(_onExitSelectionMode);
    on<MusicOverviewToggleSelectedMusic>(_onToggleSelectMusic);
    on<MusicOverviewDeleteSelected>(_onDeleteSelected);
  }

  final MusicRepository _musicRepository;
  final PlaylistRepository _playlistRepository;

  Future<void> _onSubscriptionRequested(
    MusicOverviewSubscriptionRequested event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => MusicOverviewStatus.loading));

    await _musicRepository.getAllMusicData();
    await emit.forEach<List<MusicEntity>>(
      _musicRepository
          .getMusic()
          .map((musicList) => musicList.map(MusicEntity.fromData).toList()),
      onData: (music) => state.copyWith(
        status: () => MusicOverviewStatus.success,
        music: () => music,
        selected: () => List.generate(music.length, (_) => false),
      ),
      onError: (_, __) => state.copyWith(
        status: () => MusicOverviewStatus.failure,
      ),
    );
  }

  Future<void> _onEnterSelectionMode(
    MusicOverviewEnterSelectionMode event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(state.copyWith(
        isSelectionMode: () => true,
        selected: () {
          final newSelected = List.generate(state.music.length, (_) => false);
          if (event.startIndex != null) {
            newSelected[event.startIndex!] = true;
          }
          return newSelected;
        }));
  }

  Future<void> _onExitSelectionMode(
    MusicOverviewExitSelectionMode event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(state.copyWith(
        isSelectionMode: () => false,
        selected: () {
          final newSelected = List.generate(state.music.length, (_) => false);
          return newSelected;
        }));
  }

  Future<void> _onToggleSelectMusic(
    MusicOverviewToggleSelectedMusic event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(state.copyWith(selected: () {
      final newSelected = List<bool>.from(state.selected);
      newSelected[event.index] = !newSelected[event.index];
      return newSelected;
    }));
  }

  Future<void> _onCreatePlaylists(
    MusicOverviewCreatePlaylist event,
    Emitter<MusicOverviewState> emit,
  ) async {
    final selectedMusic = state.music
        .asMap()
        .entries
        .where((entry) => state.selected[entry.key])
        .map((entry) => entry.value.toData())
        .toList();
    await _playlistRepository.createPlaylist(PlaylistWithMusicData(
      id: "",
      name: event.playlistName,
      coverImage: state.music.isNotEmpty ? selectedMusic[0].coverImage : null,
      music: selectedMusic,
    ));
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => List.generate(state.music.length, (_) => false),
    ));
  }

  Future<void> _onDeleteSelected(
    MusicOverviewDeleteSelected event,
    Emitter<MusicOverviewState> emit,
  ) async {
    await _musicRepository.deleteMusicData(
        event.selectedMusic.map((music) => music.toData()).toSet());
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => List.generate(state.music.length, (_) => false),
    ));
  }
}

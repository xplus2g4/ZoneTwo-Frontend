import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

part 'music_overview_event.dart';
part 'music_overview_state.dart';

class MusicsOverviewBloc
    extends Bloc<MusicsOverviewEvent, MusicsOverviewState> {
  MusicsOverviewBloc({
    required MusicRepository musicRepository,
    required PlaylistRepository playlistRepository,
  })  : _musicRepository = musicRepository,
        _playlistRepository = playlistRepository,
        super(const MusicsOverviewState()) {
    on<MusicsOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<MusicsOverviewCreatePlaylist>(_onCreatePlaylists);
    on<MusicOverviewEnterSelectionMode>(_onEnterSelectionMode);
    on<MusicOverviewExitSelectionMode>(_onExitSelectionMode);
    on<MusicOverviewToggleSelectedMusic>(_onToggleSelectMusic);
  }

  final MusicRepository _musicRepository;
  final PlaylistRepository _playlistRepository;

  Future<void> _onSubscriptionRequested(
    MusicsOverviewSubscriptionRequested event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => MusicsOverviewStatus.loading));

    await _musicRepository.getAllMusicData();
    await emit.forEach<List<MusicEntity>>(
      _musicRepository
          .getMusics()
          .map((musicList) => musicList.map(MusicEntity.fromData).toList()),
      onData: (musics) => state.copyWith(
        status: () => MusicsOverviewStatus.success,
        musics: () => musics,
        selected: () => List.generate(musics.length, (_) => false),
      ),
      onError: (_, __) => state.copyWith(
        status: () => MusicsOverviewStatus.failure,
      ),
    );
  }

  Future<void> _onEnterSelectionMode(
    MusicOverviewEnterSelectionMode event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    emit(state.copyWith(
        isSelectionMode: () => true,
        selected: () {
          final newSelected = List.generate(state.musics.length, (_) => false);
          if (event.startIndex != null) {
            newSelected[event.startIndex!] = true;
          }
          return newSelected;
        }));
  }

  Future<void> _onExitSelectionMode(
    MusicOverviewExitSelectionMode event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    emit(state.copyWith(
        isSelectionMode: () => false,
        selected: () {
          final newSelected = List.generate(state.musics.length, (_) => false);
          return newSelected;
        }));
  }

  Future<void> _onToggleSelectMusic(
    MusicOverviewToggleSelectedMusic event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    emit(state.copyWith(selected: () {
      final newSelected = List<bool>.from(state.selected);
      newSelected[event.index] = !newSelected[event.index];
      return newSelected;
    }));
  }

  Future<void> _onCreatePlaylists(
    MusicsOverviewCreatePlaylist event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    await _playlistRepository.createPlaylist(PlaylistWithMusicData(
      id: "",
      name: event.playlistName,
      coverImage: state.musics.isNotEmpty ? state.musics[0].coverImage : null,
      musics: state.musics
          .asMap()
          .entries
          .where((entry) => state.selected[entry.key])
          .map((entry) => entry.value.toData())
          .toList(),
    ));
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => List.generate(state.musics.length, (_) => false),
    ));
  }
}

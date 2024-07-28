import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

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
    on<MusicOverviewAddToPlaylist>(_onAddToPlaylist);
    on<MusicOverviewEnterSelectionMode>(_onEnterSelectionMode);
    on<MusicOverviewExitSelectionMode>(_onExitSelectionMode);
    on<MusicOverviewToggleSelectedMusic>(_onToggleSelectMusic);
    on<MusicOverviewDeleteSelected>(_onDeleteSelected);
    on<MusicOverviewEditMusic>(_onEditMusicInfo);
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
      selected: () => {event.id},
    ));
  }

  Future<void> _onExitSelectionMode(
    MusicOverviewExitSelectionMode event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(state.copyWith(isSelectionMode: () => false, selected: () => {}));
  }

  Future<void> _onToggleSelectMusic(
    MusicOverviewToggleSelectedMusic event,
    Emitter<MusicOverviewState> emit,
  ) async {
    emit(
      state.copyWith(
        selected: state.selected.contains(event.id)
            ? () => Set.from(state.selected)..remove(event.id)
            : () => Set.from(state.selected)..add(event.id),
      ),
    );
  }

  Future<void> _onCreatePlaylists(
    MusicOverviewCreatePlaylist event,
    Emitter<MusicOverviewState> emit,
  ) async {
    final selectedMusic = state.music
        .where((entry) => state.selected.contains(entry.id))
        .map((entry) => entry.toData())
        .toList();
    await _playlistRepository.createPlaylist(PlaylistWithMusicData(
      id: "",
      name: event.playlistName,
      coverImage: state.music.isNotEmpty ? selectedMusic[0].coverImage : null,
      music: selectedMusic,
    ));
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => {},
    ));
  }

  Future<void> _onAddToPlaylist(
    MusicOverviewAddToPlaylist event,
    Emitter<MusicOverviewState> emit,
  ) async {
    final selectedMusic = state.music
        .where((entry) => state.selected.contains(entry.id))
        .map((entry) => entry.toData())
        .toList();
    await _playlistRepository.addMusicToPlaylist(
      event.playlist.toData(),
      selectedMusic,
    );
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => {},
    ));
  }

  Future<void> _onDeleteSelected(
    MusicOverviewDeleteSelected event,
    Emitter<MusicOverviewState> emit,
  ) async {
    final selectedMusic = state.music
        .where((entry) => state.selected.contains(entry.id))
        .map((entry) => entry.toData())
        .toList();
    await _musicRepository.deleteMusicData(selectedMusic);
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => {},
    ));

    // HACK: This is a workaround to refresh the playlists
    _playlistRepository.getAllPlaylists();
    _playlistRepository.refreshCurrentPlaylistWithMusic();
  }

  Future<void> _onEditMusicInfo(
    MusicOverviewEditMusic event,
    Emitter<MusicOverviewState> emit,
  ) async {
    await _musicRepository.updateMusicData(event.music.toData());
    emit(state.copyWith(
      isSelectionMode: () => false,
      selected: () => {},
    ));
  }
}

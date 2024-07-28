import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:playlist_repository/playlist_repository.dart';
import '../entities/playlist_entity.dart';

part 'playlists_overview_event.dart';
part 'playlists_overview_state.dart';

class PlaylistsOverviewBloc
    extends Bloc<PlaylistsOverviewEvent, PlaylistsOverviewState> {
  PlaylistsOverviewBloc({
    required PlaylistRepository playlistRepository,
  })  : _playlistRepository = playlistRepository,
        super(const PlaylistsOverviewState()) {
    on<PlaylistsOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<PlaylistsOverviewPlaylistsDeleted>(_onPlaylistsDeleted);
  }

  final PlaylistRepository _playlistRepository;

  Future<void> _onSubscriptionRequested(
    PlaylistsOverviewSubscriptionRequested event,
    Emitter<PlaylistsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => PlaylistsOverviewStatus.loading));

    await _playlistRepository.getAllPlaylists();
    await emit.forEach<List<PlaylistEntity>>(
      _playlistRepository.getPlaylistsStream().map(
          (playlistList) => playlistList.map(PlaylistEntity.fromData).toList()),
      onData: (playlists) => state.copyWith(
        status: () => PlaylistsOverviewStatus.success,
        playlists: () => playlists,
      ),
      onError: (_, __) => state.copyWith(
        status: () => PlaylistsOverviewStatus.failure,
      ),
    );
  }

  Future<void> _onPlaylistsDeleted(
    PlaylistsOverviewPlaylistsDeleted event,
    Emitter<PlaylistsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => PlaylistsOverviewStatus.loading));

    await _playlistRepository.deletePlaylists(state.playlists
        .where((playlist) => event.playlistIds.contains(playlist.id))
        .map((playlist) => playlist.toData())
        .toList());
    await emit.forEach<List<PlaylistEntity>>(
      _playlistRepository.getPlaylistsStream().map(
          (playlistList) => playlistList.map(PlaylistEntity.fromData).toList()),
      onData: (playlists) => state.copyWith(
        status: () => PlaylistsOverviewStatus.success,
        playlists: () => playlists,
      ),
      onError: (_, __) => state.copyWith(
        status: () => PlaylistsOverviewStatus.failure,
      ),
    );
  }
}

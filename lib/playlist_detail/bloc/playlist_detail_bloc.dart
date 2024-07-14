import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  PlaylistDetailBloc({
    required PlaylistRepository playlistRepository,
  })  : _playlistRepository = playlistRepository,
        super(const PlaylistDetailState()) {
    on<PlaylistDetailSubscriptionRequested>(_onSubscriptionRequested);
  }

  final PlaylistRepository _playlistRepository;

  Future<void> _onSubscriptionRequested(
    PlaylistDetailSubscriptionRequested event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    await _playlistRepository.getPlaylistWithMusic(event.playlist.toData());
    await emit.forEach<List<MusicEntity>>(
      _playlistRepository
          .getPlaylistWithMusicStream()
          .map((playlist) => playlist.music.map(MusicEntity.fromData).toList()),
      onData: (music) => state.copyWith(
        music: () => music,
      ),
    );
  }
}

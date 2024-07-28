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
    required PlaylistEntity playlist,
    required PlaylistRepository playlistRepository,
  })  : _playlistRepository = playlistRepository,
        super(PlaylistDetailState(playlist)) {
    on<PlaylistDetailSubscriptionRequested>(_onSubscriptionRequested);
    on<PlaylistNameChanged>(_onNameChanged);
    on<PlaylistMusicDeleted>(_onMusicDeleted);
  }

  final PlaylistRepository _playlistRepository;

  Future<void> _onSubscriptionRequested(
    PlaylistDetailSubscriptionRequested event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    await _playlistRepository.getPlaylistWithMusic(event.playlist.toData());
    await emit.forEach<PlaylistWithMusicData>(
      _playlistRepository.getPlaylistWithMusicStream(),
      onData: (playlist) => state.copyWith(
        playlist: () => PlaylistEntity.fromData(playlist),
        music: () => playlist.music.map(MusicEntity.fromData).toList(),
      ),
    );
  }

  Future<void> _onNameChanged(
    PlaylistNameChanged event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final newPlaylist = PlaylistEntity(
      id: state.playlist.id,
      name: event.name,
      songCount: state.playlist.songCount,
      coverImage: state.playlist.coverImage,
    );
    await _playlistRepository.updatePlaylistData(
      newPlaylist.toData(),
    );
    emit(state.copyWith(
      playlist: () => newPlaylist,
    ));
  }

  Future<void> _onMusicDeleted(
    PlaylistMusicDeleted event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final newMusic = state.music.where(
      (music) => !event.musicIds.contains(music.id),
    );

    final newPlaylist = PlaylistWithMusicData(
        id: state.playlist.id,
        name: state.playlist.name,
        coverImage: state.playlist.coverImage,
        music: newMusic.map((music) => music.toData()).toList());
    await _playlistRepository.updatePlaylistMusic(newPlaylist);

    emit(state.copyWith(
      playlist: () => PlaylistEntity.fromData(newPlaylist),
      music: () => newMusic.toList(),
    ));
  }
}

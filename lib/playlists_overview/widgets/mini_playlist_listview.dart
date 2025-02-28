import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

class MiniPlaylistListview extends StatelessWidget {
  const MiniPlaylistListview(
      {required this.onPlaylistSelected, this.containsAll, super.key});

  final ValueChanged<PlaylistEntity> onPlaylistSelected;
  final bool? containsAll;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistsOverviewBloc(
        playlistRepository: context.read<PlaylistRepository>(),
      )..add(const PlaylistsOverviewSubscriptionRequested()),
      child: _MiniPlaylistListview(
          onPlaylistSelected: onPlaylistSelected,
          containsAll: containsAll ?? false),
    );
  }
}

class _MiniPlaylistListview extends StatelessWidget {
  const _MiniPlaylistListview(
      {required this.onPlaylistSelected, required this.containsAll});

  final ValueChanged<PlaylistEntity> onPlaylistSelected;
  final bool containsAll;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsOverviewBloc, PlaylistsOverviewState>(
      builder: (context, state) {
        final playlists = containsAll
            ? [PlaylistEntity.ALL_MUSIC, ...state.playlists]
            : state.playlists;
        return playlists.isEmpty
            ? const SizedBox()
            : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Material(
                      child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color: Theme.of(context).highlightColor)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: playlist.coverImage != null
                            ? Image.memory(
                                playlist.coverImage!,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              )
                            : const Icon(Icons.music_note, size: 50),
                      ),
                    ),
                    title: Text(playlist.name),
                    onTap: () {
                      onPlaylistSelected(playlist);
                    },
                  ));
                });
      },
    );
  }
}

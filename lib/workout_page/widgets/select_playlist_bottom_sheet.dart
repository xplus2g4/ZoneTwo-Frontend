import 'package:flutter/material.dart';
import 'package:zonetwo/music_player/bloc/music_player_bloc.dart';
import 'package:zonetwo/playlists_overview/entities/playlist_entity.dart';
import 'package:zonetwo/playlists_overview/widgets/mini_playlist_listview.dart';

class SelectPlaylistBottomSheet extends StatelessWidget {
  const SelectPlaylistBottomSheet(this._musicPlayerBloc, {super.key});

  final MusicPlayerBloc _musicPlayerBloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Change playlist",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: MiniPlaylistListview(onPlaylistSelected: (playlist) {
                if (playlist.id == PlaylistEntity.ALL_MUSIC.id) {
                  _musicPlayerBloc
                      .add(const MusicPlayerQueueAllMusic(playIndex: 0));
                } else {
                  _musicPlayerBloc.add(
                      MusicPlayerQueuePlaylistMusic(playlist, playIndex: 0));
                }
              Navigator.pop(context);
              },
              containsAll: true,
            ),
          ),
        ],
      ),
    );
  }
}

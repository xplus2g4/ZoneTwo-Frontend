import 'package:flutter/material.dart';
import 'package:zonetwo/music_overview/music_overview.dart';
import 'package:zonetwo/music_overview/widgets/new_playlist_dialog.dart';
import 'package:zonetwo/playlists_overview/widgets/mini_playlist_listview.dart';

class CreatePlaylistBottomSheet extends StatelessWidget {
  const CreatePlaylistBottomSheet(this.musicOverviewBloc, {super.key});

  final MusicOverviewBloc musicOverviewBloc;

  void _createPlaylistDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (_) => const NewPlaylistDialog()).then((value) {
      if (value != null) {
        musicOverviewBloc.add(MusicOverviewCreatePlaylist(value));
        Navigator.pop(context);
      }
    });
  }

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Add to playlist",
                  style: TextStyle(fontSize: 20),
                ),
                FilledButton.icon(
                  label: const Text('New'),
                  onPressed: () => _createPlaylistDialog(context),
                  icon: const Icon(Icons.playlist_add),
                ),
              ],
            ),
          ),
          Expanded(
            child: MiniPlaylistListview(onPlaylistSelected: (playlist) {
              musicOverviewBloc.add(MusicOverviewAddToPlaylist(playlist));
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
}

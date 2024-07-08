import 'package:flutter/material.dart';
import 'package:zonetwo/music_overview/bloc/music_overview_bloc.dart';
import 'package:zonetwo/music_overview/music_overview.dart';

import 'create_playlist_bottom_sheet.dart';

class CreatePlaylistFAB extends StatelessWidget {
  const CreatePlaylistFAB(this.musicOverviewBloc, {super.key});

  final MusicOverviewBloc musicOverviewBloc;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreatePlaylistBottomSheet(context),
      label: const Text('Create Playlist'),
      icon: const Icon(Icons.playlist_add),
    );
  }

  void _showCreatePlaylistBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return CreatePlaylistBottomSheet(musicOverviewBloc);
      },
    );
  }
}

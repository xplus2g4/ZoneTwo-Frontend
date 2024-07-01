import 'package:flutter/material.dart';
import 'package:zonetwo/musics_overview/bloc/musics_overview_bloc.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

import 'create_playlist_bottom_sheet.dart';

class CreatePlaylistFAB extends StatelessWidget {
  const CreatePlaylistFAB(this.musicsOverviewBloc, {super.key});

  final MusicsOverviewBloc musicsOverviewBloc;

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
        return CreatePlaylistBottomSheet(musicsOverviewBloc);
      },
    );
  }
}

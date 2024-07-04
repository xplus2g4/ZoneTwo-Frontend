import 'package:flutter/material.dart';
import 'package:zonetwo/playlists_overview/playlists_overview.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage(this.playlist, {super.key});

  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(playlist.name),
      ),
      body: const Center(
        child: Text('Playlist Detail Page'),
      ),
    );
  }
}

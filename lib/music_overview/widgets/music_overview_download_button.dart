import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zonetwo/routes.dart';

class MusicOverviewDownloadButton extends StatelessWidget {
  const MusicOverviewDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.pushNamed(musicDownloadPath),
      label: const Text('Add Music'),
      icon: const Icon(Icons.music_note_outlined),
    );
  }
}

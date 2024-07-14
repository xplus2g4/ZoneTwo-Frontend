import 'package:flutter/material.dart';
import 'package:zonetwo/music_overview/widgets/music_download_dialog.dart';

class MusicOverviewDownloadButton extends StatelessWidget {
  const MusicOverviewDownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showSimpleModalDialog(context),
      label: const Text('Add Music'),
      icon: const Icon(Icons.music_note_outlined),
    );
  }

  void _showSimpleModalDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return MusicDownloadDialog();
      },
    );
  }
}

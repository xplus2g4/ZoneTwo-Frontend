import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:zonetwo/musics_overview/widgets/musics_download_dialog.dart';

class MusicsOverviewDownloadButton extends StatelessWidget {
  MusicsOverviewDownloadButton({super.key})
      : downloadRepository = DownloadRepository();

  final DownloadRepository downloadRepository;

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
        return MusicsDownloadDialog();
      },
    );
  }
}

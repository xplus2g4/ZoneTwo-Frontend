import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:zonetwo/musics_overview/widgets/musics_download_dialog.dart';

class MusicsOverviewDownloadButton extends StatelessWidget {
  MusicsOverviewDownloadButton({super.key})
      : downloadRepository = DownloadRepository();

  final DownloadRepository downloadRepository;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showSimpleModalDialog(context),
      child: const Text('Download'),
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

import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/music_download_bloc.dart';

class MusicDownloadPage extends StatelessWidget {
  MusicDownloadPage({super.key});

  final downloadRepository = DownloadRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Music'),
      ),
      body: _MusicDownloadPage(),
    );
  }
}

class _MusicDownloadPage extends StatefulWidget {
  @override
  State<_MusicDownloadPage> createState() => _MusicDownloadPageState();
}

class _MusicDownloadPageState extends State<_MusicDownloadPage> {
  final _urlTextController = TextEditingController();

  void _onConfirm() {
    context
        .read<MusicDownloadBloc>()
        .add(DownloadClicked(link: _urlTextController.text));
    _urlTextController.text = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicDownloadBloc, MusicDownloadState>(
      builder: (context, state) {
        return Column(
          children: [
            TextField(
              controller: _urlTextController,
              autocorrect: false,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                hintText: 'Enter a YouTube link',
                errorText: state.linkValidationError,
                filled: true,
              ),
              onEditingComplete: _onConfirm,
            ),
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = state.progress[index];
                      return ListTile(
                        title: Text(
                          record.filename ?? record.url,
                          maxLines: 1,
                        ),
                        subtitle: record.error != null
                            ? Text(record.error!)
                            : record.progress == 1
                                ? const Text('Downloaded!')
                                : LinearProgressIndicator(
                                    value: record.progress),
                        trailing: record.error != null
                            ? IconButton(
                                onPressed: () => context
                                    .read<MusicDownloadBloc>()
                                    .add(RetryDownloadEvent(record.url)),
                                icon: const Icon(Icons.restart_alt),
                              )
                            : null,
                      );
                    },
                    childCount: state.progress.length,
                  ))
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:zonetwo/music_download/music_download.dart';

class MusicDownloadDialog extends StatelessWidget {
  MusicDownloadDialog({super.key}) : downloadRepository = DownloadRepository();

  final DownloadRepository downloadRepository;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicDownloadBloc(
        musicRepository: context.read<MusicRepository>(),
        downloadRepository: downloadRepository,
      ),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _AddMusicDialog(),
                _DownloadList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddMusicDialog extends StatefulWidget {
  @override
  State<_AddMusicDialog> createState() => __AddMusicDialogState();
}

class __AddMusicDialogState extends State<_AddMusicDialog> {
  final _textController = TextEditingController();
  late MusicDownloadBloc _musicDownloadBloc;

  @override
  void initState() {
    super.initState();
    _musicDownloadBloc = context.read<MusicDownloadBloc>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onEditingComplete: _onConfirm,
      onTapOutside: (event) => _onConfirm(),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        border: InputBorder.none,
        hintText: 'Enter a YouTube link',
      ),
    );
  }

  void _onConfirm() {
    _musicDownloadBloc.add(DownloadClicked(link: _textController.text));
    _textController.text = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class _DownloadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicDownloadBloc, MusicDownloadState>(
      builder: (context, state) {
        return switch (state) {
          MusicDownloadStateIdle() =>
            const Text('Please enter a term to begin'),
          MusicDownloadStateLoading() => _DownloadLoading(
              percentage: state.percentage,
            ),
          MusicDownloadStateError() => Text(state.error),
          MusicDownloadStateSuccess() => _DownloadSuccess(music: state.music)
        };
      },
    );
  }
}

class _DownloadLoading extends StatelessWidget {
  const _DownloadLoading({required this.percentage});

  final String percentage;

  @override
  Widget build(BuildContext context) {
    String percentageToString =
        percentage == '0.00' ? 'Initializing...' : 'Progress: $percentage%';
    return Row(children: [
      const SizedBox(width: 20),
      const SizedBox(
        height: 20.0,
        width: 20.0,
        child: Center(child: CircularProgressIndicator()),
      ),
      const SizedBox(width: 20),
      Text(percentageToString)
    ]);
  }
}

class _DownloadSuccess extends StatelessWidget {
  const _DownloadSuccess({required this.music});

  final MusicDownloadInfo music;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("The BPM of the music is ${music.bpm}"),
        Text("Saved at ${music.savePath}"),
      ],
    );
  }
}

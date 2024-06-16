import 'package:database/database.dart';
import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_repository/music_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'music_download/music_download.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDirectory = await getApplicationDocumentsDirectory();
  final migrator = DatabaseMigrator("${appDirectory.path}/zonetwo.db");
  final database = await migrator.open();

  final downloadRepository = DownloadRepository(appDirectory.path);
  final musicRepository = MusicRepository(database);

  runApp(App(
    musicRepository: musicRepository,
    downloadRepository: downloadRepository,
  ));
}

class App extends StatelessWidget {
  const App(
      {required this.musicRepository,
      required this.downloadRepository,
      super.key});

  final DownloadRepository downloadRepository;
  final MusicRepository musicRepository;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text('Music Download')),
            body: BlocProvider(
                create: (_) => MusicDownloadBloc(
                    musicRepository: musicRepository,
                    downloadRepository: downloadRepository),
                child: const MyHomePage())));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _AddMusicDialog(),
        _DownloadList(),
      ],
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
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        border: InputBorder.none,
        hintText: 'Enter a youtube link',
      ),
    );
  }

  void _onConfirm() {
    _musicDownloadBloc.add(DownloadClicked(link: _textController.text));
    _textController.text = '';
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
    return Row(children: [
      const CircularProgressIndicator.adaptive(),
      Text("Progress: $percentage%")
    ]);
  }
}

class _DownloadSuccess extends StatelessWidget {
  _DownloadSuccess({required this.music, AudioPlayer? player})
      : player = player ?? AudioPlayer();

  final MusicEntity music;
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("The BPM of the music is ${music.bpm}"),
        Text("Saved at ${music.savePath}"),
        ElevatedButton(
          onPressed: () async {
            switch (player.state) {
              case PlayerState.stopped:
                player.play(DeviceFileSource(music.savePath));
                break;
              case PlayerState.playing:
                player.pause();
                break;
              case PlayerState.paused:
                player.resume();
                break;
              default:
                player.play(DeviceFileSource(music.savePath));
            }
          },
          child: const Text('Play'),
        ),
      ],
    );
  }
}

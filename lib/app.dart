import 'package:download_repository/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_download/bloc/music_download_bloc.dart';
import 'package:zonetwo/music_player/music_player.dart';

import 'home/home.dart';
import 'theme/theme.dart';

class App extends StatelessWidget {
  const App(
      {required this.musicRepository,
      required this.playlistRepository,
      required this.downloadRepository,
      super.key});

  final MusicRepository musicRepository;
  final PlaylistRepository playlistRepository;
  final DownloadRepository downloadRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(providers: [
      RepositoryProvider.value(value: musicRepository),
      RepositoryProvider.value(value: playlistRepository),
      RepositoryProvider.value(value: downloadRepository)
    ], child: const AppView());
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => MusicPlayerBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => MusicDownloadBloc(
            downloadRepository: context.read<DownloadRepository>(),
            musicRepository: context.read<MusicRepository>(),
          ),
        )
      ],
      child: MaterialApp(
        theme: FlutterZoneTwoTheme.dark,
        darkTheme: FlutterZoneTwoTheme.dark,
        home: const HomePage(),
      ),
    );
  }
}

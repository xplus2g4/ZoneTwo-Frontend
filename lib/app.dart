import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:zonetwo/music_player/music_player.dart';

import 'home/home.dart';
import 'theme/theme.dart';

class App extends StatelessWidget {
  const App(
      {required this.musicRepository,
      required this.playlistRepository,
      super.key});

  final MusicRepository musicRepository;
  final PlaylistRepository playlistRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(providers: [
      RepositoryProvider.value(value: musicRepository),
      RepositoryProvider.value(value: playlistRepository),
    ], child: const AppView());
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MusicPlayerBloc(),
      child: MaterialApp(
        theme: FlutterZoneTwoTheme.dark,
        darkTheme: FlutterZoneTwoTheme.dark,
        home: const HomePage(),
      ),
    );
  }
}

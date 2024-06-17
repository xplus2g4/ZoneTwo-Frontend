import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:zonetwo/musics_overview/views/musics_overview_page.dart';

import 'theme/theme.dart';

class App extends StatelessWidget {
  const App({required this.musicRepository, super.key});

  final MusicRepository musicRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: musicRepository,
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlutterZoneTwoTheme.dark,
      darkTheme: FlutterZoneTwoTheme.dark,
      home: const MusicsOverviewPage(),
    );
  }
}

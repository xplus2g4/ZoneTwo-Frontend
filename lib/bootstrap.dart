import 'dart:io';

import 'package:database/database.dart';
import 'package:download_repository/download_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/app.dart';
import 'package:zonetwo/settings/settings.dart';

void bootstrap(
    {required Database database, required Directory downloadDirectory}) {
  final musicRepository = MusicRepository(database);
  final playlistRepository = PlaylistRepository(database);
  final downloadRepository = DownloadRepository(
    baseUrl: SettingsRepository.backendApi.value,
  );
  final workoutRepository = WorkoutRepository(database);

  runApp(App(
    musicRepository: musicRepository,
    playlistRepository: playlistRepository,
    downloadRepository: downloadRepository,
    workoutRepository: workoutRepository,
  ));
}

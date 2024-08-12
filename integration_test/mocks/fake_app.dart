import 'package:database/database.dart';
import 'package:download_repository/download_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/app.dart';
import 'package:zonetwo/settings/settings.dart';

Future<Widget> fakeApp() async {
  final appDirectory = await getApplicationDocumentsDirectory();
  final migrator = DatabaseMigrator("${appDirectory.path}/zonetwo.db");
  final database = await migrator.open();
  await SettingsRepository.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb ? HydratedStorage.webStorageDirectory : appDirectory,
  );

  final musicRepository = MusicRepository(database);
  final playlistRepository = PlaylistRepository(database);
  final downloadRepository = DownloadRepository();
  final workoutRepository = WorkoutRepository(database);

  return App(
    musicRepository: musicRepository,
    playlistRepository: playlistRepository,
    downloadRepository: downloadRepository,
    workoutRepository: workoutRepository,
  );
}

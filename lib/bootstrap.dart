import 'dart:io';

import 'package:database/database.dart';
import 'package:flutter/widgets.dart';
import 'package:music_repository/music_repository.dart';
import 'package:zonetwo/app.dart';

void bootstrap(
    {required Database database, required Directory downloadDirectory}) {
  final musicRepository = MusicRepository(database);

  runApp(App(musicRepository: musicRepository));
}

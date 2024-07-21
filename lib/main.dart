import 'package:database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zonetwo/bootstrap.dart';

import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDirectory = await getApplicationDocumentsDirectory();
  final migrator = DatabaseMigrator("${appDirectory.path}/zonetwo.db");
  final database = await migrator.open();
  await SettingsRepository.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  bootstrap(database: database, downloadDirectory: appDirectory);
}

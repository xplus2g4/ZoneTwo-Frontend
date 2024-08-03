import 'package:database/database.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/flutter_background.dart';
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

  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "ZoneTwo is running in the background",
    notificationText:
        "Keep this notification to enable ZoneTwo to run in the background",
    notificationImportance: AndroidNotificationImportance.Default,
  );
  bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
  if (success) await FlutterBackground.enableBackgroundExecution();

  bool? isBatteryOptimizationDisabled =
      await DisableBatteryOptimization.isBatteryOptimizationDisabled;
  if (isBatteryOptimizationDisabled == false) {
    DisableBatteryOptimization
        .showDisableManufacturerBatteryOptimizationSettings(
            "Your device has additional battery optimization",
            "Disable them to allow the app to work in the background.");
  }

  bootstrap(database: database, downloadDirectory: appDirectory);
}

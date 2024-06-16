import 'package:database/database.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zonetwo/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDirectory = await getApplicationDocumentsDirectory();
  final migrator = DatabaseMigrator("${appDirectory.path}/zonetwo.db");
  final database = await migrator.open();

  bootstrap(database: database, downloadDirectory: appDirectory);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/settings/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  late var defaultBpm = SettingsRepository.defaultBpm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
              leading: const Icon(Icons.music_note),
              trailing: Text(defaultBpm.toString()),
              title: Text(SettingsEnum.defaultBpm.label),
              subtitle: const Text('Set the default BPM for the app'),
              onTap: () {
                context.pushNamed(
                  settingsEditFieldPath,
                  extra: FieldEditPageArguments(
                    fieldName: SettingsEnum.defaultBpm.label,
                    initialValue: SettingsRepository.defaultBpm.toString(),
                    onConfirm: (String newValue) {
                      SettingsRepository.setDefaultBpm(int.parse(newValue))
                          .then((_) {
                        setState(() {
                          defaultBpm = int.parse(newValue);
                        });
                        context.pop();
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())));
                      });
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}

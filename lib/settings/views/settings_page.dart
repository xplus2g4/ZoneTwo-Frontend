import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zonetwo/music_player/music_player.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/settings/settings.dart';
import 'package:zonetwo/settings/widgets/manual_input_bpm_dialog.dart';
import 'package:zonetwo/utils/widgets/appbar_actions.dart';

import '../widgets/field_edit_option_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  late var defaultBpm = SettingsRepository.defaultBpm;
  late var themeMode = SettingsRepository.themeMode.value;
  late final MusicPlayerBloc _musicPlayerBloc;
  late num _bpm;

  @override
  void initState() {
    super.initState();
    _musicPlayerBloc = context.read<MusicPlayerBloc>();
    _bpm = _musicPlayerBloc.state.bpm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: AppBarActions.getActions(),
      ),
      body: ListView(
        children: [
          ListTile(
              leading: const Icon(Icons.music_note),
              trailing: BlocListener<MusicPlayerBloc, MusicPlayerState>(
                listenWhen: (previous, current) => previous.bpm != current.bpm,
                listener: (context, state) => setState(() {
                  _bpm = state.bpm;
                }),
                child: Text(_bpm.toString()),
              ),
              title: Text(SettingsEnum.manualBpm.label),
              subtitle: const Text('Manually set the adjusted BPM for BPMSync'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => ManualInputBpmDialog(
                    _bpm,
                  ),
                ).then((bpm) {
                  final value = int.tryParse(bpm);
                  if (value != null) {
                    _musicPlayerBloc.add(MusicPlayerSetBpm(
                        value.abs() > 300 ? 300 : value.abs()));
                    setState(() {
                      _bpm = bpm;
                    });
                  }
                });
              }),
          ListTile(
            leading: const Icon(Icons.palette),
            trailing: Text(themeMode.name),
            title: Text(SettingsEnum.themeMode.label),
            subtitle: const Text('Set the theme for the app'),
            onTap: () {
              showDialog<ThemeMode>(
                context: context,
                builder: (BuildContext context) => FieldEditOptionDialog(
                    currentOption: themeMode, options: ThemeMode.values),
              ).then((value) {
                if (value != null) {
                  SettingsRepository.setThemeMode(value).then((_) {
                    setState(() {
                      themeMode = value;
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  });
                }
              });
            },
          ),
          ListTile(
              leading: const Icon(Icons.perm_device_information),
              title: Text(SettingsEnum.requestPermission.label),
              subtitle: const Text(
                  'Tap to request permissions needed to run ZoneTwo in the background'),
              onTap: () {
                Permission.notification.request();
                DisableBatteryOptimization
                    .showDisableBatteryOptimizationSettings();
              }),
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('FAQ'),
            subtitle: const Text('Learn more about the app'),
            onTap: () {
              context.pushNamed(settingsFaqPath);
            },
          ),
        ],
      ),
    );
  }
}

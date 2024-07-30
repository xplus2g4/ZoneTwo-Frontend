import 'package:flutter/material.dart';
import 'package:zonetwo/playlists_overview/bloc/playlists_overview_bloc.dart';
import 'package:zonetwo/workout_overview/widgets/start_workout_bottom_sheet.dart';

class StartWorkoutButton extends StatelessWidget {
  const StartWorkoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (_) => const StartWorkoutBottomSheet());
      },
      label: Text('Start Workout', style: TextStyle(color: Colors.red[100])),
      icon: Icon(
        Icons.directions_run,
        color: Colors.red[100],
      ),
      backgroundColor: Colors.red[600]!,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/music_overview/bloc/music_overview_bloc.dart';
import 'package:zonetwo/playlists_overview/widgets/delete_confirmation_dialog.dart';
import 'package:zonetwo/routes.dart';
import 'package:zonetwo/workout_detail/views/workout_detail_page.dart';
import 'package:zonetwo/workout_overview/entities/workout_entity.dart';
import 'package:zonetwo/workout_overview/widgets/start_workout_button.dart';

import '../bloc/workout_overview_bloc.dart';
import '../widgets/workout_list_tile.dart';

class WorkoutOverviewPage extends StatelessWidget {
  const WorkoutOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WorkoutOverviewBloc(
              workoutRepository: context.read<WorkoutRepository>(),
                  )..add(const WorkoutOverviewSubscriptionRequested())),
          BlocProvider(
              create: (context) => WorkoutOverviewBloc(
                    workoutRepository: context.read<WorkoutRepository>(),
                  )..add(const WorkoutOverviewSubscriptionRequested())),
          BlocProvider(
              create: (context) => MusicOverviewBloc(
                    musicRepository: context.read<MusicRepository>(),
                    playlistRepository: context.read<PlaylistRepository>(),
                  )..add(const MusicOverviewSubscriptionRequested()))
        ],
        child: BlocListener<WorkoutOverviewBloc, WorkoutOverviewState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == WorkoutOverviewStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text("Error"),
                  ),
                );
            }
          },
          child: const WorkoutOverviewView(),
        ));
  }
}

class WorkoutOverviewView extends StatefulWidget {
  const WorkoutOverviewView({super.key});

  @override
  WorkoutOverviewViewState createState() => WorkoutOverviewViewState();
}

class WorkoutOverviewViewState extends State<WorkoutOverviewView> {
  bool _isSelectionMode = false;
  Set<String> _selectedWorkouts = {};

  void _enterSelectionMode(WorkoutEntity workout) {
    setState(() {
      _isSelectionMode = true;
      _selectedWorkouts = {};
    });
    _toggleSelection(workout);
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedWorkouts = {};
    });
  }

  void _toggleSelection(WorkoutEntity workout) {
    setState(() {
      if (_selectedWorkouts.contains(workout.id)) {
        _selectedWorkouts.remove(workout.id);
      } else {
        _selectedWorkouts.add(workout.id);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutOverviewBloc, WorkoutOverviewState>(
          builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            leading: _isSelectionMode
                ? IconButton(
                    onPressed: _exitSelectionMode,
                    icon: const Icon(Icons.close))
                : null,
            title: const Text("Workout History"),
            actions: [
              if (_isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                  disabledColor: Theme.of(context).disabledColor,
                  onPressed: _selectedWorkouts.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const DeleteConfirmationDialog(),
                          ).then((value) {
                            if (value == true) {
                              context.read<WorkoutOverviewBloc>().add(
                                    WorkoutOverviewWorkoutsDeleted(
                                        _selectedWorkouts.toList()),
                                  );
                              _exitSelectionMode();
                            }
                          });
                        },
                ),
            ],
          ),
          floatingActionButton: const StartWorkoutButton(),
          body: Builder(builder: (context) {
            if (state.workouts.isEmpty) {
              if (state.status == WorkoutOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != WorkoutOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    "The start of an epic journey...",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }
            return ListView.builder(
              itemCount: state.workouts.length,
              itemBuilder: (context, index) => WorkoutListTile(
                  workout: state.workouts[index],
                  onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(state.workouts[index]);
                        } else {
                          context.goNamed(workoutDetailPath,
                              extra: WorkoutDetailPageArguments(
                                  state.workouts[index]));
                        }
                      },
                      onLongPress: () {
                        _enterSelectionMode(state.workouts[index]);
                      },
                      isSelectionMode: _isSelectionMode,
                      isSelected:
                          _selectedWorkouts.contains(state.workouts[index].id),
                    ));
          }));
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';
import 'package:playlist_repository/playlist_repository.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/music_overview/bloc/music_overview_bloc.dart';
import 'package:zonetwo/playlists_overview/bloc/playlists_overview_bloc.dart';
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
              create: (context) => PlaylistsOverviewBloc(
                    playlistRepository: context.read<PlaylistRepository>(),
                  )..add(const PlaylistsOverviewSubscriptionRequested())),
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
  late PlaylistsOverviewBloc _playlistsOverviewBloc;
  late WorkoutOverviewBloc _workoutOverviewBloc;

  @override
  void initState() {
    super.initState();
    _playlistsOverviewBloc = context.read<PlaylistsOverviewBloc>();
    _workoutOverviewBloc = context.read<WorkoutOverviewBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutOverviewBloc, WorkoutOverviewState>(
          builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Workout History"),
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
                    //TODO: workout details
                  }),
            );
          }));
    });
  }
}

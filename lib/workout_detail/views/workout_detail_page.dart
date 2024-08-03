import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/workout_detail/bloc/workout_detail_bloc.dart';
import 'package:zonetwo/workout_overview/entities/workout_entity.dart';

class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage(this.workout, {super.key});

  final WorkoutEntity workout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutDetailBloc(
        workout: workout,
        workoutRepository: context.read<WorkoutRepository>(),
      )..add(WorkoutDetailSubscriptionRequested(workout)),
      child: const WorkoutDetail(),
    );
  }
}

class WorkoutDetail extends StatefulWidget {
  const WorkoutDetail({super.key});

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO
    return const SizedBox.shrink();
  }
}

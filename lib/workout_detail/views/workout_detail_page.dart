import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/utils/functions/format_datetime.dart';
import 'package:zonetwo/utils/functions/format_duration.dart';
import 'package:zonetwo/workout_detail/bloc/workout_detail_bloc.dart';
import 'package:zonetwo/workout_detail/widget/workout_detail_map.dart';
import 'package:zonetwo/workout_overview/entities/workout_entity.dart';
import 'package:zonetwo/workout_page/bloc/workout_page_bloc.dart';

class WorkoutDetailPageArguments {
  const WorkoutDetailPageArguments(this.workout);

  final WorkoutEntity workout;
}

class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({required this.workout, super.key});

  final WorkoutEntity workout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutDetailBloc(
        workout: workout,
        workoutRepository: context.read<WorkoutRepository>(),
      )..add(WorkoutDetailSubscriptionRequested(workout)),
      child: const WorkoutDetailPageView(),
    );
  }
}

class WorkoutDetailPageView extends StatefulWidget {
  const WorkoutDetailPageView({super.key});

  @override
  State<WorkoutDetailPageView> createState() => WorkoutDetailPageViewState();
}

class WorkoutDetailPageViewState extends State<WorkoutDetailPageView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workout Details'),
        ),
        body: BlocBuilder<WorkoutDetailBloc, WorkoutDetailState>(
            builder: (context, state) {
          return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(children: [
                SizedBox(
                  height: 300,
                  child: WorkoutDetailMap(
                      workoutId: state.workout.id, points: state.points),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      "Workout on ${formatDatetime(state.workout.datetime)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                ),
                Text(
                  formatDuration(state.workout.duration),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            const Text(
                              'Distance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      color: Colors.black45,
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.workout.distance.toStringAsFixed(2)}km',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      color: Colors.black45,
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                  fontWeight: FontWeight.bold),
                            )
                          ])),
                      const VerticalDivider(
                        color: Colors.white60,
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          const Text(
                            'Average Pace',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    color: Colors.black45,
                                    blurRadius: 3.0,
                                  ),
                                ],
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            WorkoutPageBloc.pace(
                                state.workout.distance, state.workout.duration),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    color: Colors.black45,
                                    blurRadius: 3.0,
                                  ),
                                ],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                    ])),
              ]));
        }));
  }
}

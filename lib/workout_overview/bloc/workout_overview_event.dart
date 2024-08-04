part of 'workout_overview_bloc.dart';

sealed class WorkoutOverviewEvent extends Equatable {
  const WorkoutOverviewEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutOverviewSubscriptionRequested extends WorkoutOverviewEvent {
  const WorkoutOverviewSubscriptionRequested();
}

final class WorkoutOverviewWorkoutsDeleted extends WorkoutOverviewEvent {
  const WorkoutOverviewWorkoutsDeleted(this.workoutIds);

  final List<String> workoutIds;

  @override
  List<Object> get props => [workoutIds];
}

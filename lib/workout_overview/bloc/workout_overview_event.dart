part of 'workout_overview_bloc.dart';

sealed class WorkoutOverviewEvent extends Equatable {
  const WorkoutOverviewEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutOverviewSubscriptionRequested extends WorkoutOverviewEvent {
  const WorkoutOverviewSubscriptionRequested();
}

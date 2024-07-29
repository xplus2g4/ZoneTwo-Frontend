part of 'workout_overview_bloc.dart';

enum WorkoutOverviewStatus { initial, loading, success, failure }

final class WorkoutOverviewState extends Equatable {
  const WorkoutOverviewState({
    this.status = WorkoutOverviewStatus.initial,
    this.workouts = const [],
  });

  final WorkoutOverviewStatus status;
  final List<WorkoutEntity> workouts;

  WorkoutOverviewState copyWith({
    WorkoutOverviewStatus Function()? status,
    List<WorkoutEntity> Function()? workouts,
  }) {
    return WorkoutOverviewState(
      status: status != null ? status() : this.status,
      workouts: workouts != null ? workouts() : this.workouts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        workouts,
      ];
}

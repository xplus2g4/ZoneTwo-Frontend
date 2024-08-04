part of 'workout_detail_bloc.dart';

final class WorkoutDetailState extends Equatable {
  const WorkoutDetailState(this.workout, {this.points = const []});

  final WorkoutEntity workout;
  final List<WorkoutPoint> points;

  WorkoutDetailState copyWith({
    WorkoutEntity Function()? workout,
    List<WorkoutPoint> Function()? points,
  }) {
    return WorkoutDetailState(
      workout != null ? workout() : this.workout,
      points: points != null ? points() : this.points,
    );
  }

  @override
  List<Object> get props => [workout];
}

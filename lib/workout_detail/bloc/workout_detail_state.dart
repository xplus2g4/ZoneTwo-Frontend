part of 'workout_detail_bloc.dart';

final class WorkoutDetailState extends Equatable {
  const WorkoutDetailState(this.workout, {this.music = const []});

  final WorkoutEntity workout;
  final List<MusicEntity> music;

  WorkoutDetailState copyWith({
    WorkoutEntity Function()? workout,
    List<MusicEntity> Function()? music,
  }) {
    return WorkoutDetailState(
      workout != null ? workout() : this.workout,
    );
  }

  @override
  List<Object> get props => [workout, music];
}

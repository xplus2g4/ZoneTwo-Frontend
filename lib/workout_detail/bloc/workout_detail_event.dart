part of 'workout_detail_bloc.dart';

sealed class WorkoutDetailEvent extends Equatable {
  const WorkoutDetailEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutDetailSubscriptionRequested extends WorkoutDetailEvent {
  const WorkoutDetailSubscriptionRequested(this.workout);

  final WorkoutEntity workout;

  @override
  List<Object> get props => [workout];
}

final class WorkoutNameChanged extends WorkoutDetailEvent {
  const WorkoutNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class WorkoutMusicDeleted extends WorkoutDetailEvent {
  const WorkoutMusicDeleted(this.musicIds);

  final Set<String> musicIds;

  @override
  List<Object> get props => [musicIds];
}

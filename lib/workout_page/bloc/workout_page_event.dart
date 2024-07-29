part of 'workout_page_bloc.dart';

sealed class WorkoutPageEvent extends Equatable {
  const WorkoutPageEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutPageDurationChanged extends WorkoutPageEvent {
  const WorkoutPageDurationChanged(this.currentDuration);

  final Duration currentDuration;

  @override
  List<Object> get props => [currentDuration];
}

final class WorkoutPageDistanceChanged extends WorkoutPageEvent {
  const WorkoutPageDistanceChanged(this.distance);

  final double distance;

  @override
  List<Object> get props => [distance];
}

final class WorkoutPageStart extends WorkoutPageEvent {
  const WorkoutPageStart();
}

final class WorkoutPagePause extends WorkoutPageEvent {
  const WorkoutPagePause();
}

final class WorkoutPageResume extends WorkoutPageEvent {
  const WorkoutPageResume();
}

final class WorkoutPageStop extends WorkoutPageEvent {
  const WorkoutPageStop();
}

final class WorkoutPageSave extends WorkoutPageEvent {
  const WorkoutPageSave(this.startDatetime);

  final DateTime startDatetime;

  @override
  List<Object> get props => [startDatetime];
}

part of 'workout_page_bloc.dart';

sealed class WorkoutPageEvent extends Equatable {
  const WorkoutPageEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutPageDurationChanged extends WorkoutPageEvent {
  const WorkoutPageDurationChanged(this.duration);

  final Duration duration;

  @override
  List<Object> get props => [duration];
}

final class WorkoutPagePositionAdded extends WorkoutPageEvent {
  const WorkoutPagePositionAdded(this.position);

  final WorkoutPoint position;

  @override
  List<Object> get props => [position];
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
  const WorkoutPageSave(this.datetime, this.duration, this.distance);

  final DateTime datetime;
  final Duration duration;
  final double distance;

  @override
  List<Object> get props => [datetime, duration, distance];
}

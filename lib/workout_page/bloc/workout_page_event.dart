part of 'workout_page_bloc.dart';

sealed class WorkoutPageEvent extends Equatable {
  const WorkoutPageEvent();

  @override
  List<Object> get props => [];
}

final class WorkoutPageActivateLocation extends WorkoutPageEvent {
  const WorkoutPageActivateLocation();
}

final class WorkoutPageCountdownStart extends WorkoutPageEvent {
  const WorkoutPageCountdownStart();
}

final class WorkoutPageCountdownChanged extends WorkoutPageEvent {
  const WorkoutPageCountdownChanged(this.countdown);

  final int countdown;

  @override
  List<Object> get props => [countdown];
}

final class WorkoutPageCountdownOver extends WorkoutPageEvent {
  const WorkoutPageCountdownOver();
}

final class WorkoutPageDurationChanged extends WorkoutPageEvent {
  const WorkoutPageDurationChanged(this.duration);

  final Duration duration;

  @override
  List<Object> get props => [duration];
}

final class WorkoutPageDistanceChanged extends WorkoutPageEvent {
  const WorkoutPageDistanceChanged(this.distance);

  final double distance;

  @override
  List<Object> get props => [distance];
}

final class WorkoutPagePaceChanged extends WorkoutPageEvent {
  const WorkoutPagePaceChanged(this.pace);

  final String pace;

  @override
  List<Object> get props => [pace];
}

final class WorkoutPageWorkoutPointAdded extends WorkoutPageEvent {
  const WorkoutPageWorkoutPointAdded(this.point);

  final WorkoutPoint point;

  @override
  List<Object> get props => [point];
} 

final class WorkoutPageStart extends WorkoutPageEvent {
  const WorkoutPageStart();
}

final class WorkoutPageLocationChanged extends WorkoutPageEvent {
  const WorkoutPageLocationChanged(this.location);

  final Position location;

  @override
  List<Object> get props => [location];
}

final class WorkoutPageCheckpointLocationUpdated extends WorkoutPageEvent {
  const WorkoutPageCheckpointLocationUpdated(this.location);

  final Position location;

  @override
  List<Object> get props => [location];
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

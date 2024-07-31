part of 'workout_page_bloc.dart';

final class WorkoutPageState extends Equatable {
  final Stopwatch stopwatch;
  final bool isRunning;
  final Duration duration;
  final List<WorkoutPoint> points;

  const WorkoutPageState({
    required this.stopwatch,
    this.isRunning = false,
    this.duration = Duration.zero,
    this.points = const [],
  });

  WorkoutPageState copyWith({
    Stopwatch Function()? stopwatch,
    bool Function()? isRunning,
    Duration Function()? duration,
    num Function()? distance,
    List<WorkoutPoint> Function()? points,  
  }) {
    return WorkoutPageState(
      stopwatch: stopwatch != null ? stopwatch() : this.stopwatch,
      isRunning: isRunning != null ? isRunning() : this.isRunning,
      duration: duration != null ? duration() : this.duration,
      points: points != null ? points() : this.points,
    );
  }

  @override
  List<Object?> get props => [stopwatch, isRunning, duration, points];
}

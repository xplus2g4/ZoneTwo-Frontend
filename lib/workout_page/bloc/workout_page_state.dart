part of 'workout_page_bloc.dart';

final class WorkoutPageState extends Equatable {
  final Stopwatch stopwatch;
  final bool isRunning;
  final Duration currentDuration;
  final num distance;

  const WorkoutPageState({
    required this.stopwatch,
    this.isRunning = false,
    this.currentDuration = Duration.zero,
    this.distance = 0,
  });

  WorkoutPageState copyWith({
    Stopwatch Function()? stopwatch,
    bool Function()? isRunning,
    Duration Function()? currentDuration,
    num Function()? distance,
  }) {
    return WorkoutPageState(
      stopwatch: stopwatch != null ? stopwatch() : this.stopwatch,
      isRunning: isRunning != null ? isRunning() : this.isRunning,
      currentDuration:
          currentDuration != null ? currentDuration() : this.currentDuration,
      distance: distance != null ? distance() : this.distance,
    );
  }

  @override
  List<Object?> get props => [stopwatch, isRunning, currentDuration, distance];
}

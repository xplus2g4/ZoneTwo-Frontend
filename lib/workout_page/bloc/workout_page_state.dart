part of 'workout_page_bloc.dart';

final class WorkoutPageState extends Equatable {
  final Stopwatch stopwatch;
  final bool isRunning;
  final Duration duration;
  final double distance;
  final String pace;
  final List<WorkoutPoint> points;
  final bool serviceEnabled;
  final LocationPermission permission;
  final int countdown;
  final bool isCountdownStarted;
  final bool isCountdownOver;
  final Position location;
  final Position checkpointLocation;

  const WorkoutPageState({
    required this.stopwatch,
    this.isRunning = false,
    this.duration = Duration.zero,
    this.distance = 0,
    this.pace = "-",
    this.points = const [],
    this.serviceEnabled = false,
    this.permission = LocationPermission.denied,
    this.countdown = 10,
    this.isCountdownOver = false,
    this.isCountdownStarted = false,
    required this.location,
    required this.checkpointLocation,
  });

  WorkoutPageState copyWith({
    Stopwatch Function()? stopwatch,
    bool Function()? isRunning,
    Duration Function()? duration,
    double Function()? distance,
    String Function()? pace,
    List<WorkoutPoint> Function()? points,  
    bool Function()? serviceEnabled,
    LocationPermission Function()? permission,
    int Function()? countdown,
    bool Function()? isCountdownStarted,
    bool Function()? isCountdownOver,
    Position Function()? location,
    Position Function()? checkpointLocation,
  }) {
    return WorkoutPageState(
      stopwatch: stopwatch != null ? stopwatch() : this.stopwatch,
      isRunning: isRunning != null ? isRunning() : this.isRunning,
      duration: duration != null ? duration() : this.duration,
      distance: distance != null ? distance() : this.distance,
      pace: pace != null ? pace() : this.pace,
      points: points != null ? points() : this.points,
      serviceEnabled:
          serviceEnabled != null ? serviceEnabled() : this.serviceEnabled,
      permission: permission != null ? permission() : this.permission,
      location: location != null ? location() : this.location,
      checkpointLocation: checkpointLocation != null
          ? checkpointLocation()
          : this.checkpointLocation,
      countdown: countdown != null ? countdown() : this.countdown,
      isCountdownStarted: isCountdownStarted != null
          ? isCountdownStarted()
          : this.isCountdownStarted,
      isCountdownOver:
          isCountdownOver != null ? isCountdownOver() : this.isCountdownOver,
    );
  }

  @override
  List<Object?> get props => [
        stopwatch,
        isRunning,
        duration,
        points,
        distance,
        pace,
        serviceEnabled,
        permission,
        location,
        checkpointLocation,
        countdown,
        isCountdownOver
      ];
}

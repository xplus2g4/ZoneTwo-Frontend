import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:location/location.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/workout_overview/entities/workout_point.dart';

part 'workout_page_event.dart';
part 'workout_page_state.dart';

class WorkoutPageBloc extends Bloc<WorkoutPageEvent, WorkoutPageState> {

  static final Position _TEMP_POSITION = Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  WorkoutPageBloc(
      {required this.workoutRepository,
  })
      : super(WorkoutPageState(
            stopwatch: Stopwatch(),
            location: _TEMP_POSITION,
            checkpointLocation: _TEMP_POSITION)) {
    on<WorkoutPageActivateLocation>(_onActivateLocation);
    on<WorkoutPageCountdownStart>(_onCountdownStart);
    on<WorkoutPageCountdownChanged>(_onCountdownChanged);
    on<WorkoutPageCountdownOver>(_onCountdownOver);
    on<WorkoutPageLocationChanged>(_onLocationChanged);
    on<WorkoutPageCheckpointLocationUpdated>(_onCheckpointLocationUpdated);
    on<WorkoutPageDurationChanged>(_onDurationChanged);
    on<WorkoutPageDistanceChanged>(_onDistanceChanged);
    on<WorkoutPagePaceChanged>(_onPaceChanged);
    on<WorkoutPageStart>(_onStart);
    on<WorkoutPagePause>(_onPause);
    on<WorkoutPageResume>(_onResume);
    on<WorkoutPageStop>(_onStop);
    on<WorkoutPageSave>(_onSave);
  }

  final WorkoutRepository workoutRepository;

  late final Timer _countdownTimer;
  late final Timer _workoutTimer;
  late final StreamSubscription<Position> _locationStreamSubscription;

  Future<void> _onActivateLocation(
    WorkoutPageActivateLocation event,
    Emitter<WorkoutPageState> emit,
  ) async {
    _locationStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      if (!isClosed) {
        add(WorkoutPageLocationChanged(position));
      }
    });

    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        _locationStreamSubscription.cancel();
        emit(state.copyWith(
            serviceEnabled: () => serviceEnabled,
            permission: () => LocationPermission.denied));
        add(const WorkoutPageCountdownStart());
        return;
      }
    }

    var permission = await Geolocator.checkPermission();
    if (!(permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always)) {
      permission = await Geolocator.requestPermission();
    }

    if (!(permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always)) {
      _locationStreamSubscription.cancel();
    }

    emit(state.copyWith(
        serviceEnabled: () => serviceEnabled, permission: () => permission));
    add(const WorkoutPageCountdownStart());
    return;
  }

  Future<void> _onCountdownStart(
    WorkoutPageCountdownStart event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(isCountdownStarted: () => true));
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(WorkoutPageCountdownChanged(state.countdown - 1));
    });
  }

  Future<void> _onCountdownChanged(
    WorkoutPageCountdownChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    if (event.countdown == 0) {
      add(const WorkoutPageCountdownOver());
      add(const WorkoutPageStart());
    }
    emit(state.copyWith(countdown: () => event.countdown));
  }

  Future<void> _onCountdownOver(
    WorkoutPageCountdownOver event,
    Emitter<WorkoutPageState> emit,
  ) async {
    _countdownTimer.cancel();
    emit(state.copyWith(isCountdownOver: () => true));
  }

  Future<void> _onLocationChanged(
    WorkoutPageLocationChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(location: () => event.location));
  }

  Future<void> _onCheckpointLocationUpdated(
    WorkoutPageCheckpointLocationUpdated event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(checkpointLocation: () => event.location));
  }

  Future<void> _onDurationChanged(
    WorkoutPageDurationChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(duration: () => event.duration));
  }

  Future<void> _onDistanceChanged(
    WorkoutPageDistanceChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(distance: () => event.distance));
  }

  Future<void> _onPaceChanged(
    WorkoutPagePaceChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(pace: () => event.pace));
  }

  Future<void> _onStart(
      WorkoutPageStart event, Emitter<WorkoutPageState> emit) async {
    state.stopwatch.start();

    if (isLocationActive()) {
      add(WorkoutPageCheckpointLocationUpdated(state.location));
    }

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(WorkoutPageDurationChanged(state.stopwatch.elapsed));

      if (isLocationActive()) {
        if (state.isRunning) {
          final dt = state.location.timestamp
              .difference(state.checkpointLocation.timestamp);
          if (dt.inMilliseconds == 0) return;
          final dx = Geolocator.distanceBetween(
                  state.checkpointLocation.latitude,
                  state.checkpointLocation.longitude,
                  state.location.latitude,
                  state.location.longitude) /
              1000;
          add(WorkoutPageDistanceChanged(state.distance + dx));
          add(WorkoutPagePaceChanged(pace(dx, dt)));
        }
        add(WorkoutPageCheckpointLocationUpdated(state.location));
      }
    });
    emit(state.copyWith(isRunning: () => true));
  }

  Future<void> _onPause(
    WorkoutPagePause event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.stop();
    emit(state.copyWith(isRunning: () => false));
  }

  Future<void> _onResume(
    WorkoutPageResume event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.start();
    emit(state.copyWith(isRunning: () => true));
  }

  Future<void> _onStop(
    WorkoutPageStop event,
    Emitter<WorkoutPageState> emit,
  ) async {
    state.stopwatch.stop();
    state.stopwatch.reset();
    _workoutTimer.cancel();
    _countdownTimer.cancel();
    _locationStreamSubscription.cancel();
    emit(state.copyWith(
      isRunning: () => false,
      duration: () => Duration.zero,
      distance: () => 0.0,
    ));
  }

  Future<void> _onSave(
    WorkoutPageSave event,
    Emitter<WorkoutPageState> emit,
  ) async {
    await workoutRepository.addWorkoutData(WorkoutData.newData(
      datetime: event.datetime.toIso8601String(),
      duration: event.duration.inSeconds,
      distance: event.distance,
    ));
  }

  //Helper
  bool isLocationActive() {
    return state.serviceEnabled &&
        (state.permission == LocationPermission.whileInUse ||
            state.permission == LocationPermission.always);
  }

  String pace(double dx, Duration dt) {
    double pace = dt.inMilliseconds / 1000.0 / dx;
    if (pace.isNaN || pace.isInfinite) return "-";
    int minutes = pace ~/ 60;
    int seconds = (pace % 60).floor();
    if (minutes > 20) return "-";
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }
}

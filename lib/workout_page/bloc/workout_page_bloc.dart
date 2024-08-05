import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background/flutter_background.dart'
    as FlutterBackground;
import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:location/location.dart';
import 'package:vibration/vibration.dart';
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
    on<WorkoutPageInitializeLocation>(_onIntializeLocation);
    on<WorkoutPageCountdownStart>(_onCountdownStart);
    on<WorkoutPageCountdownChanged>(_onCountdownChanged);
    on<WorkoutPageCountdownOver>(_onCountdownOver);
    on<WorkoutPageLocationChanged>(_onLocationChanged);
    on<WorkoutPageCheckpointLocationUpdated>(_onCheckpointLocationUpdated);
    on<WorkoutPageDurationChanged>(_onDurationChanged);
    on<WorkoutPageDistanceChanged>(_onDistanceChanged);
    on<WorkoutPagePaceChanged>(_onPaceChanged);
    on<WorkoutPageWorkoutPointAdded>(_onWorkoutPointAdded);
    on<WorkoutPageStart>(_onStart);
    on<WorkoutPagePause>(_onPause);
    on<WorkoutPageResume>(_onResume);
    on<WorkoutPageStop>(_onStop);
    on<WorkoutPageSave>(_onSave);
  }

  final WorkoutRepository workoutRepository;

  late final Timer _countdownTimer;
  late final Timer _workoutTimer;
  late StreamSubscription<Position> _locationStreamSubscription;
  late Timer _canActivateLocationTimer;
  bool _isLocationActivated = false;

  Future<void> _onIntializeLocation(
    WorkoutPageInitializeLocation event,
    Emitter<WorkoutPageState> emit,
  ) async {

    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        add(const WorkoutPageCountdownStart());
        return;
      }
    }

    var permission = await Geolocator.checkPermission();
    if (!(permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always)) {
      permission = await Geolocator.requestPermission();
    }

    if (serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always)) {
      _activateLocation();
    }

    _canActivateLocationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final canActivateLocation = await Geolocator.isLocationServiceEnabled() &&
          (await Geolocator.checkPermission() ==
                  LocationPermission.whileInUse ||
              await Geolocator.checkPermission() == LocationPermission.always);
      if (canActivateLocation) {
        _activateLocation();
      } else {
        _terminateLocation();
      }
    });

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
      Vibration.hasVibrator().then((value) {
        if (value != null && value == true) Vibration.vibrate(duration: 500);
      });
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

  //will this give me a race condition? maybe, but having 2 points with the
  //same orderPriority is not a big deal
  Future<void> _onWorkoutPointAdded(WorkoutPageWorkoutPointAdded event,
      Emitter<WorkoutPageState> emit) async {
    emit(state.copyWith(
      points: () => [...state.points, event.point],
    ));
  }

  Future<void> _onStart(
      WorkoutPageStart event, Emitter<WorkoutPageState> emit) async {
    state.stopwatch.start();

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(WorkoutPageDurationChanged(state.stopwatch.elapsed));
      if (_isLocationActivated && state.isRunning) {
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
        add(WorkoutPageWorkoutPointAdded(WorkoutPoint(
          latitude: state.location.latitude,
          longitude: state.location.longitude,
          orderPriority: state.points.length,
        )));
      }
      add(WorkoutPageCheckpointLocationUpdated(state.location));
    } 
    );

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
    _canActivateLocationTimer.cancel();
    _terminateLocation();
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
    workoutRepository.addWorkoutData(WorkoutWithPointsData(
      id: "",
      datetime: event.datetime.toIso8601String(),
      duration: event.duration.inSeconds,
      distance: event.distance,
      points: event.points.map((point) => point.toData()).toList(),
    ));
  }

  //Helpers
  void _activateLocation() async {
    if (_isLocationActivated) {
      return;
    }
    const androidConfig = FlutterBackground.FlutterBackgroundAndroidConfig(
      notificationTitle: "A ZoneTwo Workout is running in the background",
      notificationText:
          "Keep this notification to enable your ZoneTwo Workout to run in the background",
        notificationImportance:
            FlutterBackground.AndroidNotificationImportance.Default,
        notificationIcon: FlutterBackground.AndroidResource(
            name: 'ic_launcher', defType: 'drawable')
    );
    bool success =
        await FlutterBackground.FlutterBackground.initialize(
        androidConfig: androidConfig);
    if (success) {
      await FlutterBackground.FlutterBackground.enableBackgroundExecution();
    }
    await Geolocator.getCurrentPosition().then((position) {
      add(WorkoutPageLocationChanged(position));
      add(WorkoutPageCheckpointLocationUpdated(position));
      add(WorkoutPageWorkoutPointAdded(WorkoutPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        orderPriority: state.points.length,
      )));
    });
    _locationStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      if (!isClosed) {
        add(WorkoutPageLocationChanged(position));
      }
    });
    _isLocationActivated = true;
  }

  void _terminateLocation() {
    if (!_isLocationActivated) {
      return;
    }
    _locationStreamSubscription.cancel();
    FlutterBackground.FlutterBackground.disableBackgroundExecution();
    _isLocationActivated = false;
  }

  static String pace(double dx, Duration dt) {
    double pace = dt.inMilliseconds / 1000.0 / dx;
    if (pace.isNaN || pace.isInfinite) return "-";
    int minutes = pace ~/ 60;
    int seconds = (pace % 60).floor();
    if (minutes > 20) return "-";
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}/km';
  }
}

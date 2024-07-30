import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:workout_repository/workout_repository.dart';

part 'workout_page_event.dart';
part 'workout_page_state.dart';

class WorkoutPageBloc extends Bloc<WorkoutPageEvent, WorkoutPageState> {
  WorkoutPageBloc(
      {required this.workoutRepository,
  })
      : super(WorkoutPageState(stopwatch: Stopwatch())) {
    on<WorkoutPageDurationChanged>(_onDurationChanged);
    on<WorkoutPageStart>(_onStart);
    on<WorkoutPageDistanceChanged>(_onDistanceChanged);
    on<WorkoutPagePause>(_onPause);
    on<WorkoutPageResume>(_onResume);
    on<WorkoutPageStop>(_onStop);
    on<WorkoutPageSave>(_onSave);
  }

  final WorkoutRepository workoutRepository;

  Future<void> _onDurationChanged(
    WorkoutPageDurationChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(currentDuration: () => event.currentDuration));
  }

  Future<void> _onStart(
      WorkoutPageStart event, Emitter<WorkoutPageState> emit) async {
    state.stopwatch.start();
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
    emit(state.copyWith(
      isRunning: () => false,
      currentDuration: () => Duration.zero,
      distance: () => 0.0,
    ));
  }

  Future<void> _onDistanceChanged(
    WorkoutPageDistanceChanged event,
    Emitter<WorkoutPageState> emit,
  ) async {
    emit(state.copyWith(distance: () => event.distance));
  }

  Future<void> _onSave(
    WorkoutPageSave event,
    Emitter<WorkoutPageState> emit,
  ) async {
    await workoutRepository.addWorkoutData(WorkoutData.newData(
      datetime: event.startDatetime.toIso8601String(),
      duration: state.currentDuration.inSeconds,
      distance: state.distance,
    ));
  }
}

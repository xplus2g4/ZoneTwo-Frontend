import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_repository/workout_repository.dart';
import 'package:zonetwo/music_overview/entities/music_entity.dart';
import 'package:zonetwo/workout_overview/entities/workout_entity.dart';

part 'workout_detail_event.dart';
part 'workout_detail_state.dart';

class WorkoutDetailBloc extends Bloc<WorkoutDetailEvent, WorkoutDetailState> {
  WorkoutDetailBloc({
    required WorkoutEntity workout,
    required WorkoutRepository workoutRepository,
  })  : _workoutRepository = workoutRepository,
        super(WorkoutDetailState(workout)) {
    on<WorkoutDetailSubscriptionRequested>(_onSubscriptionRequested);
  }

  final WorkoutRepository _workoutRepository;

  Future<void> _onSubscriptionRequested(
    WorkoutDetailSubscriptionRequested event,
    Emitter<WorkoutDetailState> emit,
  ) async {
    //TODO: Implement
  }
}

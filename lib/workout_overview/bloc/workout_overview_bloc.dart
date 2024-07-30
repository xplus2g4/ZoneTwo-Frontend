import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:workout_repository/workout_repository.dart';
import '../entities/workout_entity.dart';

part 'workout_overview_event.dart';
part 'workout_overview_state.dart';

class WorkoutOverviewBloc
    extends Bloc<WorkoutOverviewEvent, WorkoutOverviewState> {
  WorkoutOverviewBloc({
    required WorkoutRepository workoutRepository,
  })  : _workoutRepository = workoutRepository,
        super(const WorkoutOverviewState()) {
    on<WorkoutOverviewSubscriptionRequested>(_onSubscriptionRequested);
  }

  final WorkoutRepository _workoutRepository;

  Future<void> _onSubscriptionRequested(
    WorkoutOverviewSubscriptionRequested event,
    Emitter<WorkoutOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => WorkoutOverviewStatus.loading));

    await _workoutRepository.getAllWorkouts();
    await emit.forEach<List<WorkoutEntity>>(
      _workoutRepository.getWorkoutStream().map(
          (workoutList) => workoutList.map(WorkoutEntity.fromData).toList()),
      onData: (workouts) => state.copyWith(
        status: () => WorkoutOverviewStatus.success,
        workouts: () =>
            workouts..sort((a, b) => b.datetime.compareTo(a.datetime)),
      ),
      onError: (_, __) => state.copyWith(
        status: () => WorkoutOverviewStatus.failure,
      ),
    );
  }
}

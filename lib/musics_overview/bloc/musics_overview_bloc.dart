import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_repository/music_repository.dart';
import 'package:zonetwo/musics_overview/musics_overview.dart';

part 'musics_overview_event.dart';
part 'musics_overview_state.dart';

class MusicsOverviewBloc
    extends Bloc<MusicsOverviewEvent, MusicsOverviewState> {
  MusicsOverviewBloc({
    required MusicRepository musicRepository,
  })  : _musicRepository = musicRepository,
        super(const MusicsOverviewState()) {
    on<MusicsOverviewSubscriptionRequested>(_onSubscriptionRequested);
  }

  final MusicRepository _musicRepository;

  Future<void> _onSubscriptionRequested(
    MusicsOverviewSubscriptionRequested event,
    Emitter<MusicsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => MusicsOverviewStatus.loading));

    await _musicRepository.getAllMusicData();
    await emit.forEach<List<MusicEntity>>(
      _musicRepository
          .getMusics()
          .map((musicList) => musicList.map(MusicEntity.fromData).toList()),
      onData: (musics) => state.copyWith(
        status: () => MusicsOverviewStatus.success,
        musics: () => musics,
      ),
      onError: (_, __) => state.copyWith(
        status: () => MusicsOverviewStatus.failure,
      ),
    );
  }

  // void _onFilterChanged(
  //   MusicsOverviewFilterChanged event,
  //   Emitter<MusicsOverviewState> emit,
  // ) {
  //   emit(state.copyWith(filter: () => event.filter));
  // }
}

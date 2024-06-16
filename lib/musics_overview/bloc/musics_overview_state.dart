part of 'musics_overview_bloc.dart';

enum MusicsOverviewStatus { initial, loading, success, failure }

final class MusicsOverviewState extends Equatable {
  const MusicsOverviewState({
    this.status = MusicsOverviewStatus.initial,
    this.musics = const [],
    // this.filter = TodosViewFilter.all,
  });

  final MusicsOverviewStatus status;
  final List<MusicEntity> musics;
  // final TodosViewFilter filter;

  // Iterable<MusicEntity> get filteredTodos => filter.applyAll(todos);

  MusicsOverviewState copyWith({
    MusicsOverviewStatus Function()? status,
    List<MusicEntity> Function()? musics,
    // TodosViewFilter Function()? filter,
  }) {
    return MusicsOverviewState(
      status: status != null ? status() : this.status,
      musics: musics != null ? musics() : this.musics,
      // filter: filter != null ? filter() : this.filter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        musics,
        // filter,
      ];
}

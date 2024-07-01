part of 'musics_overview_bloc.dart';

enum MusicsOverviewStatus { initial, loading, success, failure }

final class MusicsOverviewState extends Equatable {
  const MusicsOverviewState({
    this.status = MusicsOverviewStatus.initial,
    this.musics = const [],
    this.isSelectionMode = false,
    this.selected = const [],
    // this.filter = TodosViewFilter.all,
  });

  final MusicsOverviewStatus status;
  final List<MusicEntity> musics;
  final bool isSelectionMode;
  final List<bool> selected;
  // final TodosViewFilter filter;

  // Iterable<MusicEntity> get filteredTodos => filter.applyAll(todos);

  MusicsOverviewState copyWith({
    MusicsOverviewStatus Function()? status,
    List<MusicEntity> Function()? musics,
    bool Function()? isSelectionMode,
    List<bool> Function()? selected,
    // TodosViewFilter Function()? filter,
  }) {
    return MusicsOverviewState(
      status: status != null ? status() : this.status,
      musics: musics != null ? musics() : this.musics,
      isSelectionMode:
          isSelectionMode != null ? isSelectionMode() : this.isSelectionMode,
      selected: selected != null ? selected() : this.selected,
      // filter: filter != null ? filter() : this.filter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        musics,
        isSelectionMode,
        selected,
        // filter,
      ];
}

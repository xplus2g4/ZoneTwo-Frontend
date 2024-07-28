part of 'music_overview_bloc.dart';

enum MusicOverviewStatus { initial, loading, success, failure }

final class MusicOverviewState extends Equatable {
  const MusicOverviewState({
    this.status = MusicOverviewStatus.initial,
    this.music = const [],
    this.isSelectionMode = false,
    this.selected = const {},
    // this.filter = TodosViewFilter.all,
  });

  final MusicOverviewStatus status;
  final List<MusicEntity> music;
  final bool isSelectionMode;
  final Set<String> selected;

  // final TodosViewFilter filter;

  // Iterable<MusicEntity> get filteredTodos => filter.applyAll(todos);

  MusicOverviewState copyWith({
    MusicOverviewStatus Function()? status,
    List<MusicEntity> Function()? music,
    bool Function()? isSelectionMode,
    Set<String> Function()? selected,
    // TodosViewFilter Function()? filter,
  }) {
    return MusicOverviewState(
      status: status != null ? status() : this.status,
      music: music != null ? music() : this.music,
      isSelectionMode:
          isSelectionMode != null ? isSelectionMode() : this.isSelectionMode,
      selected: selected != null ? selected() : this.selected,
      // filter: filter != null ? filter() : this.filter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        music,
        isSelectionMode,
        selected,
        // filter,
      ];
}

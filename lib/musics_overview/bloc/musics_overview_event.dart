part of 'musics_overview_bloc.dart';

sealed class MusicsOverviewEvent extends Equatable {
  const MusicsOverviewEvent();

  @override
  List<Object> get props => [];
}

final class MusicsOverviewSubscriptionRequested extends MusicsOverviewEvent {
  const MusicsOverviewSubscriptionRequested();
}

// class MusicsOverviewFilterChanged extends MusicsOverviewEvent {
//   const MusicsOverviewFilterChanged(this.filter);

//   final TodosViewFilter filter;

//   @override
//   List<Object> get props => [filter];
// }

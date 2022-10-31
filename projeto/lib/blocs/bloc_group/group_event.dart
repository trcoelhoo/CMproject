part of 'group_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}



class GroupSearch extends SearchEvent {}

class GroupCancelSearch extends SearchEvent {}

class GroupCreate extends SearchEvent {
  final List<Player> players;
  GroupCreate({required this.players});
  @override
  List<Object?> get props => [players];
}

part of 'group_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class GroupSearching extends SearchState {}

class GroupCancelSearching extends SearchState {}

class GroupCreating extends SearchState {
  final List<Player> players;
  GroupCreating({required this.players});
  @override
  List<Object?> get props => [players];
}



class GroupInitial extends SearchState {}
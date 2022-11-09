import 'dart:async';
import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';


import '../../main.dart';
part 'group_event.dart';
part 'group_state.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(GroupInitial());
  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    if(event is GroupSearch){
      yield* _GroupSearchToState(event);
    }
    else if(event is GroupCancelSearch){
      yield* _GroupCancelSearchToState(event);
    }
    else if(event is GroupCreate){
      yield* _GroupCreateToState(event);
    }
  }

  Stream<SearchState> _GroupSearchToState(GroupSearch event) async* {
    yield GroupSearching();
  }

  Stream<SearchState> _GroupCancelSearchToState(GroupCancelSearch event) async* {
    yield GroupCancelSearching();
  }

  Stream<SearchState> _GroupCreateToState(GroupCreate event) async* {
    yield GroupCreating(players: event.players);
  }
}

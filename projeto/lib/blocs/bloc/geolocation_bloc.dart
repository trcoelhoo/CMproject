import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto/repositories/geo/geolocation_rep.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final GeolocationRep _geolocationRep;
  StreamSubscription? _geolocationSubscription;

  GeolocationBloc({required GeolocationRep geolocationRep}) : 
  _geolocationRep = geolocationRep, super(GeolocationLoading());
  
  @override
  Stream<GeolocationState> mapEventToState(
    GeolocationEvent event,
  ) async* {
    if (event is LoadGeoLocation) {
      yield* _mapLoadGeoLocationToState();
    } else if (event is UpdateGeoLocation) {
      yield* _mapUpdateGeoLocationToState(event);
    }
  }

  Stream<GeolocationState> _mapLoadGeoLocationToState() async* {
    try {
      _geolocationSubscription?.cancel();
      final position = await _geolocationRep.getCurrentPosition();
      add(UpdateGeoLocation(position: position));
    } catch (_) {
      yield GeolocationError();
    }
  }

  Stream<GeolocationState> _mapUpdateGeoLocationToState(
      UpdateGeoLocation event) async* {
    yield GeolocationLoaded(position: event.position);
  }

  @override
  Future<void> close() {
    _geolocationSubscription?.cancel();
    return super.close();
  }
}

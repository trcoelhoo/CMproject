import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bloc/bloc.dart';
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
    }
    else if (event is NewMarkers) {
      yield* _mapNewMarkersToState(event);
    }
    else if (event is UpdateGeoLocation) {
      yield* _mapUpdateGeoLocationToState(event);
    }
  }

  Stream<GeolocationState> _mapLoadGeoLocationToState() async* {
    try {
      _geolocationSubscription?.cancel();
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Future.error('Location services are disabled');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      final position = await _geolocationRep.getCurrentPosition();

      add(UpdateGeoLocation(position: position, markers: {}));
      
    } catch (_) {
      yield GeolocationError();
    }
  }

  Stream<GeolocationState> _mapNewMarkersToState(NewMarkers event) async* {
   add(UpdateGeoLocation(position: await _geolocationRep.getCurrentPosition(), markers: event.markers));
  }
  Stream<GeolocationState> _mapUpdateGeoLocationToState(
      UpdateGeoLocation event) async* {
    yield GeolocationLoaded(position: event.position );
    yield UpdatedMarkers(position: event.position, markers: event.markers);
  }

  @override
  Future<void> close() {
    _geolocationSubscription?.cancel();
    return super.close();
  }
}

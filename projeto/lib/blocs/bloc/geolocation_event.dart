part of 'geolocation_bloc.dart';


abstract class GeolocationEvent extends Equatable {
  const GeolocationEvent();
  @override
  List<Object?> get props => [];
}

class LoadGeoLocation extends GeolocationEvent {

}

class NewMarkers extends GeolocationEvent {
  final Set<Marker> markers;
  NewMarkers({required this.markers});

  @override
  List<Object?> get props => [markers];
}

class UpdateGeoLocation extends GeolocationEvent {
  final Position position;
  final Set<Marker> markers;
  UpdateGeoLocation({required this.position, required this.markers});

  @override
  List<Object?> get props => [position,markers];
}
import 'package:projeto/repositories/geo/base_geolocation_rep.dart';
import 'package:geolocator/geolocator.dart';


class GeolocationRep extends BaseGeolocationRep{
  GeolocationRep();
  @override
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

}


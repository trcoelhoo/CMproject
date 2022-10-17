import 'package:geolocator/geolocator.dart';

abstract class BaseGeolocationRep {
  Future<Position?> getCurrentPosition() async{}

}
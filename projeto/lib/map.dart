
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:geocoding/geocoding.dart';


class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  
  var markers=[];
  late BitmapDescriptor mapMarker;
  late GoogleMapController mapController;
  var cameraPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    //zoom: 14.4746,
  );

  var currentAddress = '';
  var currentPostion;
  var currentLatitude= 0.0;
  var currentLongitude= 0.0;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setMarker();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: Set<Marker>.from(markers),
            initialCameraPosition: cameraPosition,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            onMapCreated: (position) {
              setState(() {
                markers.first = markers.first.copyWith(
                  positionParam: LatLng(currentLatitude, currentLongitude),
                
                );
              });
            },
          ),
          Container(
              color: Colors.black,
              margin: EdgeInsets.only(top: 50.0),
              padding: EdgeInsets.all(10.0),
              child:Text(
                '$currentAddress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              )
        ],
      ),
          
          
        
      
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    animateCamera();
  }

  void animateCamera() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentLatitude, currentLongitude),
        zoom: 18,
        tilt:50.0,
      )));
      Marker marker = Marker(
        markerId: MarkerId('123'),
        position: LatLng(currentLatitude, currentLongitude),
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet: currentAddress,
        ),
        icon: mapMarker,
      );
      markers.add(marker);
  }

  setMarker() async {
    mapMarker= await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker.png',
    );
  }

  getCurrentLocation() async{
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position){
      setState(() {
        currentPostion = position;
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        getAddress(currentPostion);

      });
    }).catchError((e){
      print(e);
    });


  }

  getAddress(position) async{
    List<Placemark> p = await placemarkFromCoordinates(position.latitude, position.longitude);
    
    Placemark place = p[0];

    setState(() {
      currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
    });
    
    

  }
}


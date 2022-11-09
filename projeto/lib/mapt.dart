import  'package:flutter/material.dart';

import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';



class Mapt extends StatelessWidget {
  static const String routeName = '/mapt';
  
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => Mapt(),
      
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: BlocBuilder<GeolocationBloc, GeolocationState>(
              builder: (context, state){
                
                if (state is GeolocationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is GeolocationLoaded) {
                  print("current position: ${state.position.latitude}, ${state.position.longitude}");
                  final Set<Marker> markers = new Set();
                  for (var i = 0; i < Provider.of<GroupState>(context,listen: false).players.length; i++) { 
                    if (Provider.of<GroupState>(context,listen: false).players[i].position != null){
                      double lat = Provider.of<GroupState>(context,listen: false).players[i].position!.latitude;
                      double long = Provider.of<GroupState>(context,listen: false).players[i].position!.longitude;
                    markers.add(Marker(
                      markerId: MarkerId(Provider.of<GroupState>(context,listen: false).players[i].name),
                      position: LatLng(lat, long),
                      infoWindow: InfoWindow(
                        title: Provider.of<GroupState>(context,listen: false).players[i].name,
                        snippet: "Latitude: ${lat}, Longitude: ${long}",
                      ),
                    ));
                    }
                  }
                  return GoogleMap(
                    myLocationEnabled: true,
                    markers: markers,
                    
                    initialCameraPosition: CameraPosition(
                      target: LatLng(state.position.latitude, state.position.longitude),
                      zoom: 19,
                    ),
                   
                  );
                  
                  
                    
            
                } else if (state is UpdatedMarkers){
                  //get markers from state
                  final Set<Marker> markersn = state.markers;
                  return GoogleMap(
                    myLocationEnabled: true,
                    markers: markersn,
                    
                    initialCameraPosition: CameraPosition(
                      target: LatLng(state.position.latitude, state.position.longitude),
                      zoom: 19,
                    ),
                   
                  );
                }
                else {
                  return const Center(
                    child: Text('Something went wrong!'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
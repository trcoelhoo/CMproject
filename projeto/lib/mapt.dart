import  'package:flutter/material.dart';
import 'package:projeto/map.dart';
import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



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
                  return GoogleMap(
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(state.position.latitude, state.position.longitude),
                      zoom: 15,
                    ),
                  );
                    
            
                } else {
                  return const Center(
                    child: Text('Erro ao carregar o mapa'),
                  );
                }
              },
              
            )
          )
        ],
      ),
    );
  }
}
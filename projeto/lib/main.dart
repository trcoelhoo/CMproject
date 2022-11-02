
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto/group_lobby.dart';
import 'package:projeto/mapt.dart';
import 'package:projeto/repositories/geo/geolocation_rep.dart';
import 'package:projeto/repositories/geo/base_geolocation_rep.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto/save_night.dart';
import 'package:provider/provider.dart';
import 'package:pub_sub/pub_sub.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:pub_sub/json_rpc_2.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:projeto/group_create.dart';
import 'package:projeto/group.dart';
import 'package:projeto/drunktest.dart';
import 'package:projeto/group_join.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GroupState(),
    child: MyApp(),

  ));
  
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();

  
  // This widget is the root of your application.

}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver {
  
  bool _isConnected = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed || state == AppLifecycleState.inactive) {
      _isConnected = true;
      print("LOCATION SENT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      //get current location, latitude and longitude

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Uint8List bytes = Uint8List.fromList(position.toString().codeUnits);
      //print ("Bytes: $bytes");

      //print ("Position latitude: $position ");
      //send current location to group
      for (var i = 0; i < Provider.of<GroupState>(context,listen: false).players.length; i++) { 
        print("Sending to: ${Provider.of<GroupState>(context,listen: false).players[i].name}");
        //send current location to group
        //Nearby().sendBytesPayload(Provider.of<GroupState>(context,listen: false).players[i].id, bytes);
        Provider.of<GroupState>(context,listen: false).client.publish(
                  "location",
                  Provider.of<GroupState>(context,listen: false).selfPlayer.name +" : " + position.toString());
        
      }
    } else {
      _isConnected = false;
      //print("Disconnected!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void init(){
    // on location received from other player save it in the list of locations
    Builder(
            builder: (context) {
              var message= Provider.of<GroupState>(context).client.subscribe("location");
                        message.then((sub) {
                          print("listening to sub");
              sub.listen((msg) {
                String name= msg.split(":")[0];
                String location= msg.split(":")[1];
                double lat= double.parse(location.split(",")[0]);
                double long= double.parse(location.split(",")[1]);
                print("Received location from $name: $location");
                for (var i = 0; i < Provider.of<GroupState>(context,listen: false).players.length; i++) { 
                  if (Provider.of<GroupState>(context,listen: false).players[i].name==name){
                    Provider.of<GroupState>(context,listen: false).players[i].position= LatLng(lat,long);
                  }
                }
              }); 
            }); 
            return Container();
            }
            
          );
  }

    @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GeolocationRep>(
          create: (context) => GeolocationRep(),
          
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GeolocationBloc(
              geolocationRep: context.read<GeolocationRep>())
              ..add(LoadGeoLocation()),
          ),
          
          
        ],
        child: MaterialApp(
          title: 'SaveNight',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/',
          routes: {
          '/': (context) => SaveNight(),
          '/map': (context) => Mapt(),
          '/group': (context) => Group(),
          '/group_create': (context) => GroupCreate(),
          '/group_join': (context) => GroupJoin(),
          '/lobby': (context) => GroupLobby(),
          '/drunktest': (context) => DrunkTest(),

          },
        ),
        
        
      ),
      
    );
    
  }


}

class GroupState with ChangeNotifier {
  List<Player> players = [];
  late Player selfPlayer;
  //For server
  bool isServerInitialized = false;
  late Server server;
  late StreamController<StreamChannel<String>> controller;
  late Stream<StreamChannel<String>> incomingconnections;
  late JsonRpc2Adapter adapter;
  //For client
  bool isClientInitialized = false;
  late JsonRpc2Client client;
  

  void addSelf(String name) {
    selfPlayer = Player(name: name, id: "This device", isHost: true, isSelf: true);
    print("Self added|!1111!!!1!!!!!!!!!!!!!!!!");
    players.add(selfPlayer);
    notifyListeners();
  }

  void addPlayer(@required String name, @required String id,isHost) {
    players.add(Player(name: name, id: id, isHost: isHost, isSelf: false));
  }

  void initializeServer() {
    if(!isServerInitialized) {
      
      server = Server();
      controller = StreamController<StreamChannel<String>>();
      incomingconnections = controller.stream;
      adapter = JsonRpc2Adapter(incomingconnections, isTrusted: true);
      server= Server([adapter])
      ..start();
      connectWithSelf();
      isServerInitialized = true;
    }else{
      
    }
  }

  void connectWithClient(String id) {
    StreamChannel<String> channel = StreamChannel(NearbyStream(id).stream, NearbyStream(id).sink);
    controller.add(channel);
  }

  void connectWithSelf() {
    LoopbackStream loopback = LoopbackStream();
    StreamChannel<String> clientchannel = StreamChannel(loopback.clientStream, loopback.clientSink);
    StreamChannel<String> serverchannel = StreamChannel(loopback.serverStream, loopback.serverSink);
    client = JsonRpc2Client(null, clientchannel);
    controller.add(serverchannel);
  }

  void connectWithServer(String id ) {
    StreamChannel<String> channel = StreamChannel(NearbyStream(id).stream, NearbyStream(id).sink);
    client = JsonRpc2Client(null, channel);
  }

  void clearGroup() {
    for (var player in players) {
      if(!player.isSelf) {
        players.remove(player);
      }
    }
    notifyListeners();
  }
}

class Player {
  String name;
  String id;
  bool isHost;
  bool isSelf;
  LatLng? position;
  Player({required this.name, required this.id, bool this.isHost=false, bool this.isSelf=false});
}

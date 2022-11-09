import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto/account.dart';
import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto/group_lobby.dart';
import 'package:projeto/mapt.dart';
import 'package:projeto/repositories/geo/geolocation_rep.dart';
import 'package:projeto/repositories/geo/base_geolocation_rep.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto/save_night.dart';
import 'package:projeto/services/auth_service.dart';
import 'package:projeto/widgets/auth_check.dart';
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
import 'package:camera/camera.dart';
import 'package:projeto/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GroupState()),
      ChangeNotifierProvider(create: (context) => AuthService()),
    ],
    child: MyApp(),
  ));
  
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  const MyApp({super.key});
  
  @override
  _MyAppState createState() => _MyAppState();

  

  // This widget is the root of your application.

}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isConnected = false;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      _isConnected = true;
      
      //get current location, latitude and longitude

      
      //print ("Bytes: $bytes");

      //print ("Position latitude: $position ");
      //send current location to group
      Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                      Provider.of<GroupState>(context,listen: false).client.publish(
                          "location",
                          Provider.of<GroupState>(context,listen: false).selfPlayer.name +
                              ":" +
                              position.latitude.toString() +
                              "," +
                              position.longitude.toString());
                  
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

  void init() {
    
    // on location received from other player save it in the list of locations
    Builder(builder: (context) {
      var mes =
          Provider.of<GroupState>(context,listen: false).client.subscribe("location");
      mes.then((sub) {
        print("listening to sublocation");
        sub.listen((msg) {
          print(msg);
          String name = msg.split(":")[0];
          String lat = msg.split(":")[1].split(",")[0];
          String long = msg.split(":")[1].split(",")[1];

          double lati = double.parse(lat);
          double longi = double.parse(long);
          for (var i = 0;
              i <
                  Provider.of<GroupState>(context, listen: false)
                      .players
                      .length;
              i++) {
            if (Provider.of<GroupState>(context, listen: false)
                    .players[i]
                    .name ==
                name) {
              Provider.of<GroupState>(context, listen: false)
                  .players[i]
                  .position = LatLng(lati, longi);
            }
            //print locations of players
            print("player name ${Provider.of<GroupState>(context, listen: false)
                .players[i].name} e pos ${Provider.of<GroupState>(context, listen: false)
                .players[i]
                .position}");
            Provider.of<GroupState>(context, listen: false).markers.add(
              Marker(
                markerId: MarkerId(Provider.of<GroupState>(context, listen: false)
                    .players[i]
                    .name),
                position: LatLng(lati, longi),
                infoWindow: InfoWindow(title: name),
              ),
            );
            BlocProvider.of<GeolocationBloc>(context).add(
                NewMarkers(markers: Provider.of<GroupState>(context, listen: false)
                    .markers));
          }
        });
      });
      return Container();
    });
  }

  @override
  Widget build(BuildContext context) {
    //see if user is logged in
    if (Provider.of<AuthService>(context).isLogged()){
      Provider.of<GroupState>(context, listen: false).addSelf(Provider.of<AuthService>(context).utilizador!.email.toString());
    }
    

    //Provider.of<GroupState>(context, listen: false).addSelf(Provider.of<AuthService>(context).utilizador!.email.toString());
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GeolocationRep>(
          create: (context) => GeolocationRep(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                GeolocationBloc(geolocationRep: context.read<GeolocationRep>())
                  ..add(LoadGeoLocation()),
          ),
        ],
        child: GetMaterialApp(
          title: 'SaveNight',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => AuthCheck(),
            '/map': (context) => Mapt(),
            '/group': (context) => Group(),
            '/group_create': (context) => GroupCreate(),
            '/group_join': (context) => GroupJoin(),
            '/lobby': (context) => GroupLobby(),
            '/drunktest': (context) => DrunkTest(),
            '/Account': (context) => Account(),
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
  Set<Marker> markers = {};

  void addSelf(String name) {
    selfPlayer =
        Player(name: name, id: "This device", isHost: true, isSelf: true);
    print("Self added|!1111!!!1!!!!!!!!!!!!!!!!");
    players.add(selfPlayer);
    notifyListeners();
  }

  void addPlayer(@required String name, @required String id, isHost) {
    players.add(Player(name: name, id: id, isHost: isHost, isSelf: false));
  }

  void initializeServer() {
    if (!isServerInitialized) {
      server = Server();
      controller = StreamController<StreamChannel<String>>.broadcast();
      incomingconnections = controller.stream;
      adapter = JsonRpc2Adapter(incomingconnections, isTrusted: true);
      server = Server([adapter])..start();
      connectWithSelf();
      isServerInitialized = true;
    } else {}
  }

  void connectWithClient(String id) {
    StreamChannel<String> channel =
        StreamChannel(NearbyStream(id).stream, NearbyStream(id).sink);
    controller.add(channel);
  }

  void connectWithSelf() {
    LoopbackStream loopback = LoopbackStream();
    StreamChannel<String> clientchannel =
        StreamChannel(loopback.clientStream, loopback.clientSink);
    StreamChannel<String> serverchannel =
        StreamChannel(loopback.serverStream, loopback.serverSink);
    client = JsonRpc2Client(null, clientchannel);
    controller.add(serverchannel);
  }
   void setHost(bool isHost) {
    selfPlayer.isHost = isHost;
    notifyListeners();
   }

  void connectWithServer(String id) {
    StreamChannel<String> channel =
        StreamChannel(NearbyStream(id).stream, NearbyStream(id).sink);
    client = JsonRpc2Client(null, channel);
  }

  void clearGroup() {
    players.clear();
    players.add(selfPlayer);
    notifyListeners();
  }
}

class Player {
  String name;
  String id;
  bool isHost;
  bool isSelf;
  LatLng? position;
  Player(
      {required this.name,
      required this.id,
      bool this.isHost = false,
      bool this.isSelf = false});
}

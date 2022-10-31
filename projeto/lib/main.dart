import 'dart:async';

import 'package:flutter/material.dart';

import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:projeto/group_join.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GroupState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
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
}

class Player {
  String name;
  String id;
  bool isHost;
  bool isSelf;
  Player({required this.name, required this.id, bool this.isHost=false, bool this.isSelf=false});
}

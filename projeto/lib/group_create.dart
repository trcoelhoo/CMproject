import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projeto/group.dart';
import 'package:projeto/repositories/group/base_group_rep.dart';
import 'package:projeto/repositories/group/group_rep.dart';
import 'package:provider/provider.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:projeto/main.dart';

class GroupCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupCreateState(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("Player Search"),
            backgroundColor: Colors.black26,
            actions: <Widget>[
              _searchButton(),
              _stopButton(),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: (){
                  Navigator.pushNamed(context, '/lobby');
                }
              )
            ],
          ),
          body: GroupCreateBody()),
    );
  }
}

class _searchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () async {
        try {
          Nearby().askBluetoothPermission();
          Nearby().askLocationAndExternalStoragePermission();
          bool a = await Nearby().startAdvertising(
              
              Provider.of<GroupState>(context,listen: false).selfPlayer.name,
              
              Strategy.P2P_STAR,
              onConnectionInitiated: (String id,ConnectionInfo info) {
              // Called whenever a discoverer requests connection
              print("$id found with ${info.endpointName}");
              connectionRequestPrompt(id, info, context);
              },
              onConnectionResult: (String id,Status status) {
              // Called when connection is accepted/rejected
              },
              onDisconnected: (String id) {
              // Callled whenever a discoverer disconnects from advertiser
              },
          );
          
          Provider.of<GroupCreateState>(context,listen: false).searchingChange(true);
          print("searching!!!!!!!!!!!!!!!!!!!!!!!!!!: ${Provider.of<GroupCreateState>(context,listen: false).isSearching}");
          
      } catch (exception) {
          // platform exceptions like unable to start bluetooth or
          // insufficient permissions
          print(exception);
      }
      }
    );
  }
}

class _stopButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () async {
      await Nearby().stopAdvertising();
      Provider.of<GroupCreateState>(context,listen: false).searchingChange(false);
      print("not searching!!!!!!!!!!!!!!!!!!!!!!!!!!: ${Provider.of<GroupCreateState>(context,listen: false).isSearching}");
      }
    
    );
  }

}

class GroupCreateState with ChangeNotifier{
  bool isSearching = false;
  void searchingChange(bool state){
    isSearching = state;
    notifyListeners();
  }
}

class GroupCreateBody extends StatefulWidget {
  @override
  _GroupCreateBodyState createState() => _GroupCreateBodyState();
}

class _GroupCreateBodyState extends State<GroupCreateBody> {
  _GroupCreateBodyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Container(
        color: Colors.black12,
      child: Column(
        children: [
          if (Provider.of<GroupCreateState>(context,listen: true).isSearching == true)
          ...[Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Searching for players", textAlign: TextAlign.center),
          ), Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Divider()]
        else
        ...[Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Not searching", textAlign: TextAlign.center),
        ),
      Divider()],
      Expanded(
        child: ListView.builder(
          itemCount: Provider.of<GroupState>(context,listen: true).players.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(Provider.of<GroupState>(context,listen: false).players[index].name),
              subtitle: Text(Provider.of<GroupState>(context,listen: false).players[index].id),
            );
          }
        ),
      )
        ]
      ),
    ));
  }
}

void connectionRequestPrompt(String id, ConnectionInfo info, BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (builder) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
           Text("${info.endpointName} wants in!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children:[
             ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.red),  child: Text("REJECT"), onPressed: () async {
               Navigator.pop(context);
               try {
                      await Nearby().rejectConnection(id);
                    } catch (exception) {
                      print(exception);
                    }}),
            ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.green), child: Text("ACCEPT"), onPressed: () async {
              Provider.of<GroupState>(context,listen: false).addPlayer(info.endpointName, id,false);
                    Navigator.pop(context);
                    Nearby().acceptConnection(
                      id,
                      onPayLoadRecieved: (endid, payload) {
                        final bytes=payload.bytes;
                        if (bytes==null) return;
                        NearbyStream(endid).receive(bytes);   
                      },
                    );
                    Provider.of<GroupState>(context,listen: false).connectWithClient(id);
            }),
           ]
         )]),
      );
    }
  );
}
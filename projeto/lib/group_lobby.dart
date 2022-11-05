import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projeto/group.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' show utf8;
import 'package:geolocator/geolocator.dart';
import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//page where the user can see his group and the other players in it and send messages to them

class GroupLobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessagesState(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("Group Lobby"),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black26,
            actions: <Widget>[
              _leaveGroupButton(),
            ],
          ),
          body: GroupLobbyBody()),
    );
  }
}

class _leaveGroupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: () async {
        try {
          await Nearby().stopAdvertising();
          await Nearby().stopDiscovery();
          await Nearby().stopAllEndpoints();
          Provider.of<MessagesState>(context,listen: false).clearMessages();
          Provider.of<GroupState>(context,listen: false).clearGroup();
          Navigator.pop(context);
          
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Group()),
          );
        } catch (e) {
          print(e);
        }
      },
    );
  }
}

class GroupLobbyBody extends StatefulWidget{
  @override
  _GroupLobbyBodyState createState() => _GroupLobbyBodyState();
}
class _GroupLobbyBodyState extends State<GroupLobbyBody> {
  _GroupLobbyBodyState();
  @override

  Widget build(BuildContext context) {
    return Column(
     
      children: <Widget>[
        Builder(
            builder: (context) {
              var message= Provider.of<GroupState>(context,listen: false).client.subscribe("messages");
                        message.then((sub) {
                          print("listening to sub");
              sub.listen((msg) {
                        
                        Provider.of<MessagesState>(context,listen: false).addMessage(Provider.of<GroupState>(context,listen: false).selfPlayer.name,utf8.encode(msg));

                        });
                        });
              return Container();
            },
          ),
          Builder(builder: (context) {
      var message =
          Provider.of<GroupState>(context).client.subscribe("location");
      message.then((sub) {
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
            BlocProvider.of<GeolocationBloc>(context).add(
                UpdateLocation());
          }
        });
      });
      
      return Container();
    }),
        _groupInfo(),
        _playersList(),
        Expanded(
          child: ListView.builder(
            itemCount: Provider.of<MessagesState>(context,listen: false).messages.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(Provider.of<MessagesState>(context,listen: false).messages[index]),
              
              );
            
            },
          ),
        ),
        _messageInput(),
      ],
    );
  }
}

class MessagesState extends ChangeNotifier {
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  void addMessage(String name, List<int> message) {
    messages.add(utf8.decode(message));
    messages=messages.toSet().toList();
    notifyListeners();
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
  



}

class _messageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: Provider.of<MessagesState>(context,listen: false).messageController,
              decoration: InputDecoration(
                hintText: "Type your message here",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              try {
                if (Provider.of<MessagesState>(context, listen: false)
                        .messageController
                        .text !=
                    "") {
                    List<int> list = utf8.encode(
                    Provider.of<MessagesState>(context, listen: false)
                        .messageController
                        .text);
                Uint8List bytes= Uint8List.fromList(list);
                
                await Nearby().sendBytesPayload(
                    Provider.of<GroupState>(context, listen: false)
                        .selfPlayer
                        .id,
                    bytes);

                    
                    

                }

              } catch (e) {
                print(e);
              }
              Provider.of<GroupState>(context,listen: false).client.publish(
                  "messages",
                  Provider.of<GroupState>(context,listen: false).selfPlayer.name + ": " +
                      Provider.of<MessagesState>(context,listen: false).messageController.text);
              
              //send location
              Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
              Provider.of<GroupState>(context,listen: false).client.publish(
                  "location",
                  Provider.of<GroupState>(context,listen: false).selfPlayer.name +
                      ":" +
                      position.latitude.toString() +
                      "," +
                      position.longitude.toString());
              Provider.of<MessagesState>(context, listen: false)
                  .messageController
                  .clear();



              

            },
          ),
        ],
      ),
    );
  }
}

class _messagesList extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: Provider.of<MessagesState>(context,listen: false).messages.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(Provider.of<MessagesState>(context,listen: false).messages[index]),
          
          );
        
        },
      ),
    );
   
  }
}

class _playersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: Provider.of<GroupState>(context,listen: false).players.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Provider.of<GroupState>(context,listen: false).players[index].name),
          );
        },
      ),
    );
  }
}

class _groupInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
          "Group name: ${Provider.of<GroupState>(context,listen:false).players.firstWhere((player) => player.isHost == true).name}'s Lobby"
      ),  );  
  }
}








/*
class MessageForm extends StatefulWidget{
  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: myController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Enter message"
              )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.send),
            onPressed: (){
              Provider.of<GroupState>(context,listen: false).client.publish("message", myController.text);
            }
          ),
        )
      ],
    );
  }
}*/
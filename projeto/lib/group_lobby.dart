import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projeto/NearbyClasses.dart';

import 'package:projeto/group.dart';

import 'package:projeto/group_join.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' show utf8;
import 'package:geolocator/geolocator.dart';
import 'package:projeto/blocs/bloc/geolocation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//page where the user can see his group and the other players in it and send messages to them


class GroupLobby extends StatefulWidget {
  @override
  _GroupLobbyState createState() => _GroupLobbyState();
}

class _GroupLobbyState extends State<GroupLobby> {

 

  List<ChatMessage> messages = [];
  final controller= TextEditingController();
  void addMessgeToList(ChatMessage  obj){

    setState(() {
      messages.insert(0, obj);
      messages=messages.reversed.toList();
    });
  }
  

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();

  }

  void init(){
    var message= Provider.of<GroupState>(context,listen: false).client.subscribe("messages");
    message.then((sub) {
      sub.listen((data) {
        var obj = ChatMessage(messageContent: data["message"], sender: data["sender"]);

        addMessgeToList(obj);
    });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group: ${Provider.of<GroupState>(context,listen:false).players.firstWhere((player) => player.isHost == true).name}'s Lobby"),
        centerTitle: true,
        backgroundColor: Colors.black26,
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () async {
                      try {
                        await Nearby().stopAdvertising();
                        await Nearby().stopDiscovery();
                        await Nearby().stopAllEndpoints();

                        Provider.of<GroupState>(context,listen: false).clearGroup();
                        Navigator.pop(context);
                        
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Group()),
                        );
                        dispose();
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),

      ),
      body: Column(
        children: [
          _playersList(),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10,bottom: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                  child: Align(
                    alignment: (messages[index].sender==Provider.of<GroupState>(context,listen: false).selfPlayer.name)?Alignment.topRight:Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (messages[index].sender==Provider.of<GroupState>(context,listen: false).selfPlayer.name)?Colors.black26:Colors.grey.shade200,
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text(messages[index].messageContent,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                          SizedBox(height: 5,),
                          Text(messages[index].sender,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),
                          
                        ],
                      ),

                    ),
                  ),
                );
                
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    print("client ${Provider.of<GroupState>(context,listen: false).client.clientId}");
                    var message= Provider.of<GroupState>(context,listen: false).client.publish("messages",{"message": controller.text, "sender": Provider.of<GroupState>(context,listen: false).selfPlayer.name});
                    message.then((value) {
                      var obj = ChatMessage(messageContent: controller.text, sender: Provider.of<GroupState>(context,listen: false).selfPlayer.name);
                      addMessgeToList(obj);
                      controller.clear();
                    });
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
         
        ],
      ),
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
  List<Player> players = [];
  List<Player> playersfix = [];
  @override
  Widget build(BuildContext context) {
    //remove duplicates from players list
    players = Provider.of<GroupState>(context, listen: false).players;
    playersfix = players.toSet().toList();
    
    return Expanded(
      child: ListView.builder(
        itemCount: playersfix.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(playersfix[index].name),
            subtitle: Text(playersfix[index].id),
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

class ChatMessage{
  String messageContent;
  String sender;
  ChatMessage({ required this.messageContent,  required this.sender});
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



import 'package:flutter/material.dart';
import 'package:projeto/group.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      messages.insert(messages.length, obj);
      
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
        for (var i = 0;
              i <
                  Provider.of<GroupState>(context, listen: false)
                      .players
                      .length;
              i++) {
            if (Provider.of<GroupState>(context, listen: false)
                    .players[i]
                    .name ==
                data["sender"]) {
              Provider.of<GroupState>(context, listen: false)
                  .players[i]
                  .position = LatLng(data["lat"], data["long"]);
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
                position: LatLng(data["lat"], data["long"]),
                infoWindow: InfoWindow(title: data["sender"]),
              ),
            );
        BlocProvider.of<GeolocationBloc>(context).add(
                NewMarkers(markers: Provider.of<GroupState>(context, listen: false)
                    .markers));
          }
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
                  onPressed: () async {
                    print("client ${Provider.of<GroupState>(context,listen: false).client.clientId}");
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                    var message= Provider.of<GroupState>(context,listen: false).client.publish("messages",{"message": controller.text, "sender": Provider.of<GroupState>(context,listen: false).selfPlayer.name, "lat": position.latitude, "long": position.longitude});
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


class ChatMessage{
  String messageContent;
  String sender;
  ChatMessage({ required this.messageContent,  required this.sender});
}





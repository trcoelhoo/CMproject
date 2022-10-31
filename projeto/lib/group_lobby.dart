import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projeto/group.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert' show utf8;

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

class GroupLobbyBody extends StatelessWidget {
  @override
  MessagesState createState() => MessagesState();
  Widget build(BuildContext context) {
    return Column(
     
      children: <Widget>[
        Builder(
            builder: (context) {
              var greetingcatch = Provider.of<GroupState>(context).client.subscribe("messages");
                        greetingcatch.then((sub) {
                          print("listening to sub");
              sub.listen((msg) {
                        print('got a greeting');
                        final snackBar = SnackBar(content: Text("Got a greeting! It says: $msg"),);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Provider.of<MessagesState>(context,listen: false).addMessage("Player",msg);
                        });
                        });
              return Container();
            },
          ),
        _groupInfo(),
        _playersList(),
        _messagesList(),
        _messageInput(),
      ],
    );
  }
}

class MessagesState extends ChangeNotifier {
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  void addMessage(String name, String message) {
    messages.add(name + ": " + message);
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
              controller: Provider.of<MessagesState>(context).messageController,
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

                    print("message sent ${Provider.of<MessagesState>(context, listen: false).messages}");
                    Provider.of<MessagesState>(context, listen: false)
                        .addMessage(
                            Provider.of<GroupState>(context, listen: false)
                                .selfPlayer
                                .name,
                            Provider.of<MessagesState>(context, listen: false)
                                .messageController
                                .text);

                }

              } catch (e) {
                print(e);
              }
              Provider.of<GroupState>(context,listen: false).client.publish(
                  "messages",
                  Provider.of<GroupState>(context,listen: false).selfPlayer.name + ": " +
                      Provider.of<MessagesState>(context,listen: false).messageController.text);



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
        itemCount: Provider.of<MessagesState>(context).messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Provider.of<MessagesState>(context).messages[index]),
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
        itemCount: Provider.of<GroupState>(context).players.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Provider.of<GroupState>(context).players[index].name),
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
          "Group name: ${Provider.of<GroupState>(context).players.firstWhere((player) => player.isHost == true).name}'s Lobby"
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
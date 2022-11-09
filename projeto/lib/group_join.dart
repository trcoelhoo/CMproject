
import 'package:flutter/material.dart';
import 'package:projeto/group.dart';
import 'package:projeto/NearbyClasses.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/group_lobby.dart';
import 'package:projeto/main.dart';
import 'package:provider/provider.dart';
//page where the user can connect to an existing group by nearby connection

class GroupJoin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => JoinsState(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("Host Search"),
            backgroundColor: Colors.black26,
            actions: <Widget>[
              _hostSearchButton(),
              _hostSearchStopButton(),
            ],
          ),
          body: GroupJoinBody()),
    );
  }
}

class _hostSearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () async {
        
        try {
        //request permissions
          Nearby().askBluetoothPermission();
          Nearby().askLocationAndExternalStoragePermission();

          bool a = await Nearby().startDiscovery(
          
          Provider.of<GroupState>(context,listen:false).selfPlayer.name,
          Strategy.P2P_STAR,
          onEndpointFound: (String id,String userName, String serviceId) {
            print("$id found with name $userName and $serviceId");
            Provider.of<JoinsState>(context,listen: false).addHost(id, userName, serviceId);

          },
          onEndpointLost:
          (String? id) {
            print("$id lost");
            
          },
          );
          print("searching");
          
        
        } catch (e) {
          print(e);
          Provider.of<JoinsState>(context,listen: false).searchingChange(false);
        }
        print("searching");
        Provider.of<JoinsState>(context,listen: false).searchingChange(true);
      }
    );
  }
}

class _hostSearchStopButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () async {
      await Nearby().stopDiscovery();
      //disconnect from all hosts
      Provider.of<JoinsState>(context,listen: false).disconnectAll();
      Provider.of<JoinsState>(context,listen: false).searchingChange(false);
    }
    );
  }

}

class JoinsState with ChangeNotifier{
  bool isSearching = false;
  List<Host> HostList = [];
void searchingChange(bool state){
  isSearching = state;
  notifyListeners();
}
void addHost (String id, String userName, String serviceId){
  if (HostList.every((element) => element.id != id)){
  HostList.add(Host(id, userName, serviceId));
  notifyListeners();} else {print("$userName $id already discovered");}
}
void disconnectAll(){
  HostList.forEach((element) {
    Nearby().disconnectFromEndpoint(element.id);
  });
  HostList = [];
  notifyListeners();
}
}

class Host extends StatelessWidget {
  final String id;
  final String userName;
  final String serviceId;
  Host(this.id, this.userName, this.serviceId);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(userName),
      subtitle: Text(id),
      trailing: ElevatedButton(
        child: Text("CONNECT"),
        onPressed: (){
          print("This device wants to connect with $userName");
          try{
    Nearby().requestConnection(
        Provider.of<GroupState>(context,listen: false).selfPlayer.name,
        id,
        onConnectionInitiated: (id, info) {
          connectionRequestPrompt(id, info, context);
        },
        onConnectionResult: (id, status) {
        },
        onDisconnected: (id) {
        },
    );
    }catch(exception){
        print(exception);
        }
        }
      )
    );
  }
}

class GroupJoinBody extends StatefulWidget {
  @override
  _GroupJoinBodyState createState() => _GroupJoinBodyState();
}

class _GroupJoinBodyState extends State<GroupJoinBody> {
  _GroupJoinBodyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black12,
        child:Column(
        
        children: [
          if (Provider.of<JoinsState>(context,listen: true).isSearching == true)
          ...[Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Searching for hosts", textAlign: TextAlign.center),
          ), Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Divider()],
        if (Provider.of<JoinsState>(context,listen: true).isSearching == false)
        ...[Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Not searching", textAlign: TextAlign.center),
        ),
      Divider(),],
    Expanded(
      child: ListView.builder(
        itemCount: Provider.of<JoinsState>(context).HostList.length,
        itemBuilder: (BuildContext context, int index) {
          return Provider.of<JoinsState>(context).HostList[index];
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
             ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.red),child: Text("REJECT"), onPressed: () async {
               Navigator.pop(context);
               try {
                      await Nearby().rejectConnection(id);
                    } catch (exception) {
                      print(exception);
                    }}),
            ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.green), child: Text("ACCEPT"), onPressed: () {
              Provider.of<GroupState>(context,listen:false).addPlayer(info.endpointName,id,false);
                    Navigator.pop(context);
                    
                    Nearby().acceptConnection(
                      id,
                      onPayLoadRecieved: (endid, payload) {

                        final bytes=payload.bytes;
                        if (bytes==null) return;
                        NearbyStream(endid).receive(bytes);  
                        
                      },
                    );
                    Provider.of<GroupState>(context,listen: false).connectWithServer(id);
                    Provider.of<GroupState>(context,listen: false).setHost(false);
                    Provider.of<GroupState>(context,listen: false).players[1].isHost = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupLobby()),
                    );
            }),
           ]
         )]),
      );
    }
  );
}
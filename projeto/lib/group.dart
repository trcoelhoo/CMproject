
import 'package:flutter/material.dart';

import 'package:projeto/group_create.dart';
import 'package:projeto/group_join.dart';
import 'package:provider/provider.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:projeto/main.dart';

//page where the user can create a new group or connect to an existing group by nearby connection
class Group extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Select a Connection"),
          backgroundColor: Colors.black26,

        ),
        body: GroupBody());
  }
}

class GroupBody extends StatelessWidget {
  final controller = TextEditingController();
  @override
  
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child:Padding(
      padding: const EdgeInsets.all(8.0),

      
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Hi, ${Provider.of<GroupState>(context).selfPlayer.name}! You can create a new group or join an existing one by nearby connection.",style: TextStyle(fontSize: 20),),
          
          
          Container(
            
            child: Column(children: [
              
              
            Padding(
              
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black38,
                ),
              
                child: Text("Create a new group",
                    style: TextStyle(fontSize: 17,
                    color: Colors.white)),
                    
                onPressed: () {
                  Provider.of<GroupState>(context, listen: false).addSelf("name");
                  Nearby().askLocationPermission();
                  print("Offer pressed");
                  Provider.of<GroupState>(context, listen: false).selfPlayer.isHost=true;
                  Provider.of<GroupState>(context, listen: false).initializeServer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreate(),
                    ),
                  );
                },
              ),
            ),
            Container(
              child: Text(
                "or",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black38,
                ),
                
                child: Text("Join a nearby group",
                    style: TextStyle(fontSize: 17)),
                onPressed: () {
                  Nearby().askLocationPermission();
                  print("Join pressed");
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupJoin(),
                    ),
                  );
                },
              ),
            )
          ])),

        ],
      ),
    ),
    );

  }
}
/*
class Group extends StatelessWidget {
  const Group({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              "Create a new group",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            child: Text(
              "or",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            child: Text(
              "Join a nearby group",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              child: Text("Create"),
              onPressed: () {
                Nearby().askLocationAndExternalStoragePermission();
                Provider.of<GroupState>(context).selfPlayer.isHost = true;
                Provider.of<GroupState>(context).initializeServer();
                Navigator.pushNamedAndRemoveUntil(context, '/group_create', (_) => false);

              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 90, 25, 101),
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              child: Text("Join"),
              onPressed: () {
                Nearby().askLocationAndExternalStoragePermission();
                Navigator.pushNamedAndRemoveUntil(context, '/group_join' , (_) => false);
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 90, 25, 101),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/




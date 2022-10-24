import 'package:flutter/material.dart';
import 'package:projeto/group.dart';

//page where the user can connect to an existing group by nearby connection

class Join extends StatelessWidget {
  const Join({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          title: Text("Join a nearby group"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Group(),
                ),
              );
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
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
                child: Text("Join"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Group(),
                    ),
                  );
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
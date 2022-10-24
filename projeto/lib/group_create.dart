import 'package:flutter/material.dart';
import 'package:projeto/group.dart';

//page where the user can create a new group 

class Create extends StatelessWidget {
  const Create({super.key});

  @override
  Widget build(BuildContext context) {

    // add back button to the appbar and spacee to create the group
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Text("Create a new group"),
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
              "Create a new group",
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
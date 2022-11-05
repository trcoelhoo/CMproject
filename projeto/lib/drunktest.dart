import 'dart:async';


import 'package:ionicons/ionicons.dart';


import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DrunkTest extends StatefulWidget {
  @override
  _DrunkTestState createState() => _DrunkTestState();
}
// game with gyroscope and accelerometer to test if the user is drunk
// the user has to move a circle to the center of the screen and keep it there for 2 seconds

class _DrunkTestState extends State<DrunkTest> {
  StreamSubscription? _subscription;
  double _gyroscopeXvalue=0;
  double _gyroscopeYvalue=0;
  double _gyroscopeZvalue=0;
  Timer timer = Timer(Duration(seconds: 2), () {});
  
  void init() {
    DateTime startTime= new DateTime.now();
    int count=0;
    int time=0;
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _gyroscopeXvalue = num.parse(event.x.toStringAsFixed(1)).toDouble();
        _gyroscopeYvalue =  num.parse(event.y.toStringAsFixed(1)).toDouble();
        _gyroscopeZvalue =  num.parse(event.z.toStringAsFixed(1)).toDouble();
      });
      });

      //start timer till user puts the circle in the center
      timer = Timer.periodic(Duration(seconds:1), (timer) { 
        time+=1;
        if(_gyroscopeXvalue < 0.5 && _gyroscopeXvalue > -0.4 && _gyroscopeYvalue < 0.4 && _gyroscopeYvalue > -0.4 && _gyroscopeZvalue > 9.5 && _gyroscopeZvalue < 10.5){
          count+=1;
          //print("User is not drunk");
          //show dialog
          if (count==5){
            DateTime endTime= new DateTime.now();
            int difference= endTime.difference(startTime).inMicroseconds;
            double seconds= difference/1000000-5;
            print("difference: $seconds");
            double drunk_percentage= (seconds*100/30);
            drunk_percentage= num.parse(drunk_percentage.toStringAsFixed(2)).toDouble();
            timer.cancel();
            _subscription!.cancel();
            _subscription = null;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("You are ${drunk_percentage}% drunk!"),

                  actions: [
                    TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _subscription!.cancel();
                        _subscription = null;
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        else{
          count=0;
          //print("User is drunk");
          //show dialog
          if (time==40){
            double drunk_percentage= (time/40)*100;
            timer.cancel();
            _subscription!.cancel();
            _subscription = null;
            
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  
                  title: Text("You are ${drunk_percentage}% drunk!"),
                  content: Text("You are not allowed to drive!"),

                  actions: [
                   
                    TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _subscription!.cancel();  
                        _subscription = null;
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      });

      
      /*timer = Timer(Duration(seconds: 2), () {
        //print("Timer ended");
        //print("X: $_gyroscopeXvalue");
        //print("Y: $_gyroscopeYvalue");
        //print("Z: $_gyroscopeZvalue");
        //if the user is drunk, the circle will move
        if(_gyroscopeXvalue < 0.3 && _gyroscopeXvalue > -0.3 && _gyroscopeYvalue < 0.3 && _gyroscopeYvalue > -0.3 && _gyroscopeZvalue > 9.5 && _gyroscopeZvalue < 10.5){
          
          //print("User is not drunk");
          //show dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You are not drunk!"),
                content: Text("You can drive!"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _subscription!.cancel();
                      _subscription = null;
                    },
                  ),
                ],
              );
            },
          );
        }
        else{
          //print("User is drunk");
          //show dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You are drunk!"),
                content: Text("You are not allowed to drive!"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _subscription!.cancel();
                      _subscription = null;
                    },
                  ),
                ],
              );
            },
          );
        }
      });
      */


    
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  setColor(){
    if(_gyroscopeXvalue < 0.5 && _gyroscopeXvalue > -0.4 && _gyroscopeYvalue < 0.4 && _gyroscopeYvalue > -0.4 && _gyroscopeZvalue > 9.5 && _gyroscopeZvalue < 10.5){
      return Colors.yellow;
    }
    else{
      return Colors.red;
    }
  }
  @override
  // watch circle move with gyroscope
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drunk Test'),
        backgroundColor: Colors.black26
      ),
      body: 
        Container(
          color: Colors.black12,
          child:
        Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('DrunkTest:'),
            Text('Keep the beer in the center of the screen for 5 seconds'),
            Text('Don\'t waist beer!'),
            // circle that moves with gyroscope
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: setColor(),
                shape: BoxShape.circle,
              ),
              child: Transform.translate(
                offset: Offset(_gyroscopeXvalue*20, _gyroscopeYvalue*30),
                child: Icon(Ionicons.beer_outline,
                size: 80,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  init();
                },
                child: Text('Start'),
              ),
            ),
            
          ],
        ),
      ),
    )
    );
  }
}





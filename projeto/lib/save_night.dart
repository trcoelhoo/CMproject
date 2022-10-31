import 'package:flutter/material.dart';
import 'package:projeto/mapt.dart';
import 'package:ionicons/ionicons.dart';
import 'package:projeto/group.dart';
import "package:persistent_bottom_nav_bar/persistent_tab_view.dart";
import 'package:projeto/group_create.dart';


class SaveNight extends StatefulWidget {
  const SaveNight({Key? key}) : super(key: key);

  @override
  State<SaveNight> createState() => _SaveNightState();
}

class _SaveNightState extends State<SaveNight> {
  
  final List<Widget> tabs = [
    Mapt(),
    Group(),

  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Center( child: const Text("Save Night",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ),

        
        backgroundColor: Colors.black,  
      ),
            body: PersistentTabView(
        context,
        screens: tabs,
        items: _navBarsItems(),
      ),
      
    );

  }
  

  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Ionicons.earth_outline),
        title: ("Map"),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Ionicons.people_circle_outline),
        title: ("Group"),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),

    ];
  }
  /*
  Widget _bottomNavBar(int selectedIndex) => SizedBox(
        height: 47.8,
        child: BottomNavigationBar(
          elevation: 2.5,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) => setState(() => _selectedIndex = index),
          currentIndex: selectedIndex,
          selectedFontSize: 12.0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(fontSize: 0.0),
          unselectedLabelStyle: TextStyle(fontSize: 0.0),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 46,
                child: Stack(
                  children: [
                    selectedIndex == 0
                        ? Container(
                            height: 4.8,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.black,

                            ),
                            alignment: Alignment.topCenter,
                          )
                        : Container(
                          width: 44.0),
                          Container(
                            height: 46,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              
                                Ionicons.earth_outline,
                                color: selectedIndex == 0
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                          ),


                    
                  ],
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 46,
                child: Stack(
                  children: [
                    selectedIndex == 1
                        ? Container(
                            height: 4.8,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                            color: Colors.black,

                            ),
                            alignment: Alignment.topCenter,
                          )
                        : Container(
                          width: 44.0),
                          Container(
                            height: 46,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                                
                                  Ionicons.people_circle_outline,
                                  color: selectedIndex == 1
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                          ),
                  ],
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 46,
                child: Stack(
                  children: [
                    selectedIndex == 2
                        ? Container(
                            height: 4.8,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.black,

                            ),
                            alignment: Alignment.topCenter,
                          )
                        : Container(
                          width: 44.0),
                          Container(
                            height: 46,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                                
                                  Ionicons.camera_outline,
                                  color: selectedIndex == 2
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                          ),
                  ],
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 46,
                child: Stack(
                  children: [
                    selectedIndex == 2
                        ? Container(
                            height: 4.8,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.black,

                            ),
                            alignment: Alignment.topCenter,
                          )
                        : Container(
                          width: 44.0),
                          Container(
                            height: 46,
                            width: 44.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0.0),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.0),
                                bottomLeft: Radius.circular(50.0),
                                topRight: Radius.circular(0.0),
                                bottomRight: Radius.circular(50.0),
                              ),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                                
                                  Ionicons.beer_outline,
                                  color: selectedIndex == 2
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                          ),
                  ],
                ),
              ),
              label: '',
            ),
          ],
        ),
      );


      
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            body: PageStorage(
              child: tabs[_selectedIndex],
              bucket: bucket,
            ),
            bottomNavigationBar: _bottomNavBar(_selectedIndex),
          );
        }
        */
}



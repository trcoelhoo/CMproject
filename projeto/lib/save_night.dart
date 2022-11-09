import 'package:flutter/material.dart';

import 'package:projeto/account.dart';
import 'package:projeto/mapt.dart';
import 'package:ionicons/ionicons.dart';
import 'package:projeto/group.dart';
import "package:persistent_bottom_nav_bar/persistent_tab_view.dart";
import 'package:projeto/drunktest.dart';
import 'package:projeto/camera.dart';

class SaveNight extends StatefulWidget {
  const SaveNight({Key? key}) : super(key: key);

  @override
  State<SaveNight> createState() => _SaveNightState();
}

class _SaveNightState extends State<SaveNight> {
  final List<Widget> tabs = [
    Mapt(),
    Group(),
    DrunkTest(),
    Camera(),
    Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "Save Night",
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
      PersistentBottomNavBarItem(
        icon: const Icon(Ionicons.beer_outline),
        title: ("Drunk Test"),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Ionicons.camera_outline),
        title: ("Camera"),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Ionicons.apps_outline),
        title: ("Account"),
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
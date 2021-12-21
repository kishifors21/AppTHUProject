import 'dart:async';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;

import 'package:app/components/CARcontroller.dart';
import 'package:app/components/common.dart';

class CARApp extends StatelessWidget {
  CARApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehical Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // declare variable
  String uri_ip = '';
  var x = 0.0, y = 0.0, turn = 0.0;
  var speed = 0.0, direction = 0.0;
  Map last_wheels = {'lf': 0.0, 'rf': 0.0, 'lb': 0.0, 'rb': 0.0};
  var wheelsTimer;

  void initState() {
    uri_ip = globals.uri;
    super.initState();
    wheelsTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      last_wheels = wheelFunc(speed, direction, turn, last_wheels, uri_ip);

      print(last_wheels);
    });
  }

  @override
  void dispose() {
    wheelsTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
      commonPage(pageType: 'driver_video'),
      movePosition(
        joystickFunc: (var joystickDistance, var joystickDirection) async {
          setState(() {
            speed = joystickDistance * 4095 / 50;
            direction = -joystickDirection;
          });
        },
        sliderFunc: (var dx) async {
          setState(() {
            turn = dx * 4095 / 50;
          });
        },
      ),
    ]);
  }
}

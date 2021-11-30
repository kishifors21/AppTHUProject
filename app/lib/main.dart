import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import 'package:app/my_flutter_app_icons.dart';
import 'package:app/CARcontroller.dart';
import 'package:app/Helmet.dart';

import "dart:math" show pi;

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homepage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Row(children: <Widget>[
        ElevatedButton(
          child: Text('Vehical Controller'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CARApp()));
          },
        ),
        ElevatedButton(
          child: Text('Helmet Display'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HelmetApp()));
          },
        ),
        ElevatedButton(
          child: Text('One-Page'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HelmetApp()));
          },
        ),
      ]),
    );
  }
}

class MaterialPagerRoute {}

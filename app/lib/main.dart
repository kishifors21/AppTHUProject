import 'package:flutter/material.dart';
import 'package:app/CARcontroller.dart';
import 'package:app/Helmet.dart';
import 'package:app/One-Page.dart';
import 'package:app/camera.dart';

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
      initialRoute: "/",
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
                context, MaterialPageRoute(builder: (context) => OnePageApp()));
          },
        ),
        // ElevatedButton(
        //   child: Text('test'),
        //   onPressed: () {
        //     Navigator.push(
        //         context, MaterialPageRoute(builder: (context) => camera()));
        //   },
        // ),
      ]),
    );
  }
}

class MaterialPagerRoute {}

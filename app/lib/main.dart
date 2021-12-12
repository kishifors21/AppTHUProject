import 'package:flutter/material.dart';
import 'package:app/CARcontroller.dart';
import 'package:app/Helmet.dart';
import 'package:app/One-Page.dart';

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
  String uri_ip = 'http://172.24.8.24:8080/';

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Row(children: <Widget>[
        ElevatedButton(
          child: Text('Vehical Controller'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CARApp(
                          uri_ip: uri_ip,
                        )));
          },
        ),
        ElevatedButton(
          child: Text('Helmet Display'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HelmetApp(uri_ip: uri_ip)));
          },
        ),
        ElevatedButton(
          child: Text('One-Page'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OnePageApp(uri_ip: uri_ip)));
          },
        ),
      ]),
    );
  }
}

class MaterialPagerRoute {}

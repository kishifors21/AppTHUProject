import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import 'components/common.dart';

import 'globals.dart' as globals;

class camera extends StatelessWidget {
  camera();
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
  // int _counter = 0;

  // declare variable
  bool islive = true;
  bool isChargeToggle = true, isTrackerToggle = true;
  // String uri_ip = 'http://192.168.1.1:8080/';
  late String uriVideo;
  String uri_ip = '';

  void initState() {
    uri_ip = globals.uri;
    uriVideo = uri_ip + 'driver_video';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        commonPage(
          pageType: 'driver_video',
        ),
        // Center(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Mjpeg(
        //         isLive: islive,
        //         error: (context, error, stack) {
        //           // print(error);
        //           // print(stack);

        //           return Text(error.toString(),
        //               style: TextStyle(color: Colors.red));
        //         },
        //         stream:
        //             // 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER',
        //             // 'http://172.24.8.23:8080/video_feed',
        //             uriVideo,
        //       ),
        //     ],
        //   ),
        // ),
        // Button(
        //   icon: Icon(Icons.settings),
        //   inkColor: Colors.lightBlue,
        //   top: 10,
        //   right: 10,
        //   func: () {
        //     // _showMyDialog();
        //   },
        // ),
      ],
    );
  }
}

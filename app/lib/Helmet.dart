import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import 'package:app/my_flutter_app_icons.dart';

import "dart:math" show pi;

class HelmetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helmet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  fetchVolt() async {
    try {
      final response = await http.get(Uri.parse(uri_ip + 'volt'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return response.body;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load');
      }
    } catch (e) {
      // print(e);
    }
  }

  void voltTimer() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      fetchVolt().then((value) => setState(() {
            _volt = value;
            // print(value);
          }));
      // print(timer.tick);
    });
  }

  // declare variable
  bool islive = true;
  bool isChargeToggle = true, isTrackerToggle = true;
  // String uri_ip = 'http://192.168.1.1:8080/';
  late String uriVideo;
  String uri_ip = 'http://192.168.1.1:8080/';
  String _volt = "-1";
  var x = 0.0, y = 0.0, turn = 0.0;
  var speed = 0.0, direction = 0.0;

  void initState() {
    uriVideo = uri_ip + 'video_feed';
    super.initState();
    voltTimer();
  }

  void getCordinates(tack_sign) async {
    try {
      await http.post(
        Uri.parse(uri_ip + 'image_roi'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'time_count': "1", 'track_sign': tack_sign}),
      );
    } catch (e) {
      // print(e);
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Mjpeg(
                isLive: islive,
                error: (context, error, stack) {
                  // print(error);
                  // print(stack);

                  return Text(error.toString(),
                      style: TextStyle(color: Colors.red));
                },
                stream:
                    // 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER',
                    // 'http://172.24.8.23:8080/video_feed',
                    uriVideo,
              ),
            ],
          ),
        ),
        new Positioned(
            top: 30,
            left: 0,
            child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Volt: $_volt',
                  style: TextStyle(
                    color: Colors.cyan.shade100.withOpacity(0.9),
                    fontSize: 17,
                    decorationColor: Colors.white.withOpacity(0),
                  ),
                ),
                // color: Colors.blueGrey.shade700.withOpacity(0.5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(3.0),
                  color: Colors.blueGrey.shade600.withOpacity(0.6),
                ))),
        // togle for charge
        Button(
          icon: Icon(Icons.bolt),
          inkColor: isChargeToggle ? Colors.lightBlue : Colors.amber,
          bottom: 150,
          right: 20,
          func: () async {
            setState(() {
              isChargeToggle = !isChargeToggle;
            });
            try {
              isChargeToggle == true
                  ? await http.get(Uri.parse(uri_ip + '?method=re'))
                  : await http.get(Uri.parse(uri_ip + '?method=re stop'));
            } catch (e) {
              // print(e);
            }
          },
        ),
        // togle for tracker
        Button(
          icon: Icon(MyFlutterApp.circular_shield),
          inkColor: isTrackerToggle ? Colors.lightBlue : Colors.amber,
          bottom: 200,
          right: 20,
          func: () async {
            setState(() {
              isTrackerToggle = !isTrackerToggle;
            });
            try {
              isTrackerToggle == true ? getCordinates(1) : getCordinates(1);
            } catch (e) {
              // print(e);
            }
          },
        ),
        // shoot
        Button(
          icon: Icon(MyFlutterApp.rifle),
          inkColor: Colors.lightBlue,
          bottom: 170,
          right: 80,
          func: () async {
            try {
              await http.get(Uri.parse(uri_ip + '?method=shot'));
            } catch (e) {
              // print(e);
            }
          },
        ),
        //setting dialog
        Button(
          icon: Icon(Icons.settings),
          inkColor: Colors.lightBlue,
          top: 10,
          right: 10,
          func: () {
            _showMyDialog();
          },
        ),
      ],
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Container(
            child: Column(children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Button(
                      icon: Icon(Icons.arrow_back),
                      func: () {
                        Navigator.pop(context);
                      },
                    ),
                  ))),
          Expanded(
              child: GestureDetector(
            child: Text(
              'refresh view',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              setState(() {
                islive = false;
              });
              await Future.delayed(Duration(milliseconds: 100));
              setState(() {
                islive = true;
              });
            },
          )),
          Expanded(
              child: GestureDetector(
            child: Text(
              'swtich view (for test)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              setState(() {
                uriVideo = uriVideo == uri_ip + 'video_feed'
                    ? 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER'
                    : uri_ip + 'video_feed';
              });
            },
          )),
        ]));
      },
    );
  }
}

// ignore: must_be_immutable
class Button extends StatefulWidget {
  var top, bottom, right, left, icon, func, inkColor, buttonColor;
  Button(
      {this.top,
      this.bottom,
      this.right,
      this.left,
      this.func,
      this.icon,
      this.inkColor = Colors.lightBlue,
      this.buttonColor = Colors.white});
  @override
  _Button createState() => _Button();
}

class _Button extends State<Button> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: widget.top == null ? null : widget.top.toDouble(),
          bottom: widget.bottom == null ? null : widget.bottom.toDouble(),
          left: widget.left == null ? null : widget.left.toDouble(),
          right: widget.right == null ? null : widget.right.toDouble(),
          height: 50,
          width: 50,
          child: Material(
            color: Colors.white.withOpacity(0),
            child: Center(
              child: Ink(
                decoration: ShapeDecoration(
                  color: widget.inkColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: widget.icon == null ? Icon(Icons.android) : widget.icon,
                  color: Colors.white,
                  onPressed: () {
                    widget.func();
                    // try {
                    //   widget.func;
                    // } catch (e) {}
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

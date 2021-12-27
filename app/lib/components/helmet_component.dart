import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app/my_flutter_app_icons.dart';

import 'package:app/globals.dart' as globals;

import 'package:another_flushbar/flushbar.dart';

import 'package:app/components/common.dart';

// ignore: must_be_immutable

class helemetwidget extends StatefulWidget {
  var up;
  helemetwidget({this.up = 0});
  @override
  _helemetwidgetState createState() => _helemetwidgetState();
}

class _helemetwidgetState extends State<helemetwidget> {
  @override
  void initState() {
    super.initState();
    messageTimer();
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  String uri_ip = globals.uri;
  void fsb(title, message, duration) async {
    await Future.delayed(Duration.zero);
    Flushbar(
      title: title,
      message: message,
      duration: duration,
    ).show(context);
  }

  bool isChargeToggle = true, isTrackerToggle = true;
  var x = 0.0, y = 0.0, turn = 0.0;
  var speed = 0.0, direction = 0.0;
  Map<String, dynamic> message = {'volt': '-1'};
  late Timer _messageTimer;
  Map<String, dynamic> last_message = {'volt': '-1', 'message': 'hello'};
  void messageTimer() {
    _messageTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      var _message;
      try {
        _message = await http.get(
          Uri.parse(uri_ip + 'info'),
        );
        _message = json.decode(_message.body);
      } catch (e) {
        print(e);
      }
      // print(json.decode(_message.body)['message']);
      // print(json.decode(_message.body)['volt']);
      setState(() {
        // _volt = message['volt'];
        message = _message;
      });
      // print(message['message']);
      if (message['message'] != last_message['message'] &&
          message['message'].toString() != '') {
        fsb('message', message['message'].toString(), Duration(seconds: 10));
      }
      last_message = message;
    });
  }

  void getCordinates(track_sign) async {
    try {
      print(track_sign);
      await http.post(
        Uri.parse(uri_ip + 'image_roi'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'time_count': track_sign.toString(),
          'track_sign': track_sign
        }),
      );
    } catch (e) {
      print(e);
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
      new Positioned(
          top: 85,
          left: 0,
          child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Volt: ${message['volt'].toString()}',
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
            isTrackerToggle == true ? getCordinates(0) : getCordinates(1);
          } catch (e) {
            print(e);
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

      // move button
      MoveButton(
        dir: 0,
        uri_ip: uri_ip,
        bottom: 90 + widget.up,
        left: 70,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      MoveButton(
        dir: 1,
        uri_ip: uri_ip,
        bottom: 150 + widget.up,
        left: 70,
        icon: Icon(
          Icons.keyboard_arrow_up,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      MoveButton(
        dir: 2,
        uri_ip: uri_ip,
        bottom: 90 + widget.up,
        left: 130,
        icon: Icon(
          Icons.keyboard_arrow_right,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      MoveButton(
        dir: 3,
        uri_ip: uri_ip,
        bottom: 90 + widget.up,
        left: 10,
        icon: Icon(
          Icons.keyboard_arrow_left,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      //zoom in and zoom out
      MoveButton(
        dir: 4,
        uri_ip: uri_ip,
        bottom: 90,
        right: 90,
        icon: Icon(
          Icons.zoom_in,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      MoveButton(
        dir: 5,
        uri_ip: uri_ip,
        bottom: 90,
        right: 20,
        icon: Icon(
          Icons.zoom_out,
          size: 50,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    ]);
  }
}

// ignore: must_be_immutable
class MoveButton extends StatefulWidget {
  var top, bottom, right, left, icon, func, inkColor, buttonColor, dir, uri_ip;
  MoveButton(
      {this.top,
      this.bottom,
      this.right,
      this.left,
      this.func,
      this.icon,
      this.dir,
      this.uri_ip,
      this.inkColor = Colors.lightBlue,
      this.buttonColor = Colors.white});
  @override
  _MoveButton createState() => _MoveButton();
}

class _MoveButton extends State<MoveButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String uri_ip = widget.uri_ip;
    return Stack(
      children: <Widget>[
        Positioned(
          top: widget.top == null ? null : widget.top.toDouble(),
          bottom: widget.bottom == null ? null : widget.bottom.toDouble(),
          left: widget.left == null ? null : widget.left.toDouble(),
          right: widget.right == null ? null : widget.right.toDouble(),
          // height: 50,
          // width: 50,
          child: Material(
            color: Colors.white.withOpacity(0),
            child: Center(
              child: Ink(
                decoration: ShapeDecoration(
                    color: Colors.cyan.shade200.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(7)))),
                child: GestureDetector(
                  child: widget.icon,
                  onTapDown: (details) {
                    // dir 0: down,  1: up,  2: right,  3: left
                    if (widget.dir < 2) {
                      Map data = {'vertical': widget.dir * 2 - 1};
                      try {
                        http.post(Uri.parse(uri_ip + 'Vrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else if (widget.dir < 4) {
                      Map data = {'horizontal': (widget.dir - 2) * 2 - 1};
                      try {
                        http.post(Uri.parse(uri_ip + 'Hrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else {
                      Map data = {'sign': widget.dir - 4};
                      try {
                        http.post(Uri.parse(uri_ip + 'tracking_size'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    }
                  },
                  onTapUp: (details) {
                    if (widget.dir < 2) {
                      Map data = {'vertical': 0};
                      try {
                        http.post(Uri.parse(uri_ip + 'Vrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else if (widget.dir < 4) {
                      Map data = {'horizontal': 0};
                      try {
                        http.post(Uri.parse(uri_ip + 'Hrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else {
                      Map data = {'sign': -1};
                      try {
                        http.post(Uri.parse(uri_ip + 'tracking_size'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    }
                  },
                  onPanEnd: (details) {
                    if (widget.dir < 2) {
                      Map data = {'vertical': 0};
                      try {
                        http.post(Uri.parse(uri_ip + 'Vrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else if (widget.dir < 4) {
                      Map data = {'horizontal': 0};
                      try {
                        http.post(Uri.parse(uri_ip + 'Hrotation'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    } else {
                      Map data = {'sign': -1};
                      try {
                        http.post(Uri.parse(uri_ip + 'tracking_size'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(data));
                      } catch (e) {}
                    }
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

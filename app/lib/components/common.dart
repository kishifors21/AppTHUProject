import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import "dart:math" show pi;
import 'package:flutter/foundation.dart';
import 'package:app/globals.dart' as globals;

class commonPage extends StatefulWidget {
  var pageType;
  commonPage({this.pageType});

  @override
  _commonPage createState() => _commonPage();
}

class _commonPage extends State<commonPage> {
  // int _counter = 0;

  // declare variable
  bool islive = true;
  // String uri_ip = 'http://192.168.1.1:8080/';
  late String uriVideo;
  String uri_ip = '';
  var x = 0.0, y = 0.0, turn = 0.0;
  var speed = 0.0, direction = 0.0;
  Map last_wheels = {'lf': 0.0, 'rf': 0.0, 'lb': 0.0, 'rb': 0.0};

  void initState() {
    uri_ip = globals.uri;
    uriVideo = uri_ip + widget.pageType;
    super.initState();
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
              '(mjpg test)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              setState(() {
                uriVideo = uriVideo == uri_ip + 'driver_video'
                    ? 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER'
                    : uri_ip + 'driver_video';
              });
            },
          )),
          Expanded(
              child: GestureDetector(
            child: Text(
              'cam reset',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Map data = {'setting': 'cam_index'};
              try {
                http.post(Uri.parse(uri_ip + 'Setting'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: json.encode(data));
              } catch (e) {}
              data = {'setting': 'pi_cam'};
              try {
                http.post(Uri.parse(uri_ip + 'Setting'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: json.encode(data));
              } catch (e) {}
            },
          )),
          Expanded(
              child: GestureDetector(
            child: Text(
              'reset modules',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Map data = {'setting': 'reset_modules'};
              try {
                http.post(Uri.parse(uri_ip + 'Setting'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: json.encode(data));
              } catch (e) {}
            },
          )),
          Expanded(
              child: GestureDetector(
            child: Text(
              'switch camera',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Map data = {'setting': 'cam_switch'};
              try {
                http.post(Uri.parse(uri_ip + 'Setting'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: json.encode(data));
              } catch (e) {}
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

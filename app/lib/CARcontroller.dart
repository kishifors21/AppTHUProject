import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import 'package:app/my_flutter_app_icons.dart';

import "dart:math" show pi;

class CARApp extends StatelessWidget {
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
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  void wheelsTimer() {
    try {
      http.post(
        Uri.parse(uri_ip + 'wheels'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'start': 'begin', 'test': 1}),
      );
    } catch (e) {}
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      // ignore: unused_local_variable
      var lf, rf, lb, rb;
      Map wheels = {'lf': 0.0, 'rf': 0.0, 'lb': 0.0, 'rb': 0.0};
      if (speed == 0) {
        wheels = {
          'lf': 0.0,
          'rf': 0.0,
          'lb': 0.0,
          'rb': 0.0,
        };
      } else if (direction.abs == pi / 2 || direction.abs == pi) {
        wheels = {
          'lf': speed,
          'rf': speed,
          'lb': speed,
          'rb': speed,
        };
      } else if (direction == 0 || direction.abs == pi) {
        wheels = {
          'lf': (direction.abs() / pi) * 2 - 1 * speed,
          'rf': (direction.abs() / pi) * 2 - 1 * -speed,
          'lb': (direction.abs() / pi) * 2 - 1 * -speed,
          'rb': (direction.abs() / pi) * 2 - 1 * speed,
        };
      } else if (pi / 2 <= direction) {
        wheels = {
          'lf': -((direction - pi / 4 * 3) / pi * 4) * speed,
          'rf': speed,
          'lb': speed,
          'rb': -((direction - pi / 4 * 3) / pi * 4) * speed,
        };
      } else if (pi / 2 > direction && direction >= 0) {
        wheels = {
          'lf': speed,
          'rf': ((direction - pi / 4) / pi * 4) * speed,
          'lb': ((direction - pi / 4) / pi * 4) * speed,
          'rb': speed,
        };
      } else if (-pi / 2 <= direction && direction <= 0) {
        wheels = {
          'lf': ((direction + pi / 4) / pi * 4) * speed,
          'rf': -speed,
          'lb': -speed,
          'rb': ((direction + pi / 4) / pi * 4) * speed,
        };
      } else if (-pi / 2 >= direction) {
        wheels = {
          'lf': -speed,
          'rf': -((direction + pi / 4 * 3) / pi * 4) * speed,
          'lb': -((direction + pi / 4 * 3) / pi * 4) * speed,
          'rb': -speed,
        };
      }
      print(wheels['lf']);
      wheels = {
        'lf': wheels['lf'] + turn,
        'rf': wheels['rf'] - turn,
        'lb': wheels['lb'] + turn,
        'rb': wheels['rb'] - turn,
      };
      wheels.forEach((key, value) {
        if (value > 4095) {
          value = 4095.0;
        } else if (value < -4095) {
          value = -4095.0;
        }
      });
      try {
        http.post(Uri.parse(uri_ip + 'wheels'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(wheels));
      } catch (e) {}
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
    wheelsTimer();
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
          bottom: 50,
          height: 100,
          width: 100,
          left: 30,
          child: JoyStick(
              func: (var joystickDistance, var joystickDirection) async {
            setState(() {
              speed = joystickDistance * 4095 / 50;
              direction = -joystickDirection;
            });
          }),
        ),
        new Positioned(
          bottom: 50,
          right: 30,
          height: 100,
          width: 100,
          child: singleAxisJoyStick(func: (var dx) async {
            setState(() {
              turn = dx * 4095 / 50;
            });
          }),
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

// ignore: must_be_immutable
class JoyStick extends StatefulWidget {
  var func;
  JoyStick({
    this.func,
  });
  @override
  _JoyStickState createState() => _JoyStickState();
}

class _JoyStickState extends State<JoyStick> {
  late Offset offset, smallCircleOffset;

  @override
  void initState() {
    offset = Offset(0.0, 0.0);
    smallCircleOffset = offset;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 100.0,
          width: 100.0,
        ),
        Positioned(
          top: 50,
          left: 50,
          child: CustomPaint(
            painter: Painter(false, this.offset, false),
            child: CustomPaint(
              painter: Painter(true, smallCircleOffset, (true)),
            ),
          ),
        ),
        GestureDetector(
          onPanEnd: (details) {
            setState(() {
              smallCircleOffset = offset;
            });
            widget.func(0.0, 0.0);
          },
          onPanUpdate: (details) {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset tmpOfsset = renderBox!.globalToLocal(details.globalPosition);
            tmpOfsset = Offset(tmpOfsset.dx - 50.0, tmpOfsset.dy - 50.0);
            // print(tmpOfsset.direction);
            if (tmpOfsset.distance < 50) {
              // if (smallCircleOffset.distance < 50) {
              setState(() {
                smallCircleOffset = tmpOfsset;
                widget.func(tmpOfsset.distance, tmpOfsset.direction);
              });
            } else {
              setState(() {
                smallCircleOffset = Offset(
                    tmpOfsset.dx * 50.0 / tmpOfsset.distance,
                    tmpOfsset.dy * 50.0 / tmpOfsset.distance);
              });
              widget.func(50, tmpOfsset.direction);
            }
          },
        ),
      ],
    );
  }
}

class Painter extends CustomPainter {
  final bool needsRepaint, isInBoundary;
  final Offset offset;
  Painter(this.needsRepaint, this.offset, this.isInBoundary);
  @override
  void paint(Canvas canvas, Size size) {
    if (needsRepaint && isInBoundary) {
      canvas.drawCircle(this.offset, 20,
          Paint()..color = Colors.cyan.shade200.withOpacity(0.6));
      canvas.drawCircle(
          this.offset,
          20,
          Paint()
            ..color = Colors.cyan.shade500.withOpacity(0.6)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke);
    } else {
      canvas.drawCircle(this.offset, 50,
          Paint()..color = Colors.blueGrey.shade600.withOpacity(0.5));
      canvas.drawCircle(
          this.offset,
          50,
          Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (needsRepaint && isInBoundary) ? true : false;
  }
}

// ignore: must_be_immutable
class singleAxisJoyStick extends StatefulWidget {
  var func;
  singleAxisJoyStick({
    this.func,
  });
  @override
  _singleAxisJoyStickState createState() => _singleAxisJoyStickState();
}

class _singleAxisJoyStickState extends State<singleAxisJoyStick> {
  late Offset offset, smallCircleOffset;
  @override
  void initState() {
    offset = Offset(0, 0);
    smallCircleOffset = offset;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 100.0,
          width: 100.0,
        ),
        Positioned(
          top: 50,
          left: 50,
          child: CustomPaint(
            painter: singleAxisPainter(false, this.offset, false),
            child: CustomPaint(
              painter: singleAxisPainter(true, smallCircleOffset, (true)),
            ),
          ),
        ),
        GestureDetector(
          onPanEnd: (details) {
            setState(() {
              smallCircleOffset = offset;
            });
            widget.func(0.0);
          },
          onPanUpdate: (details) {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset tmpOfsset = renderBox!.globalToLocal(details.globalPosition);
            tmpOfsset = Offset(tmpOfsset.dx - 50, tmpOfsset.dy - 50);

            if (tmpOfsset.distance < 50) {
              setState(() {
                smallCircleOffset = Offset(tmpOfsset.dx, 0);
              });
              widget.func(tmpOfsset.dx);
            } else {
              setState(() {
                smallCircleOffset =
                    Offset(tmpOfsset.dx * 50 / tmpOfsset.distance, 0);
              });
            }
          },
        ),
      ],
    );
  }
}

class singleAxisPainter extends CustomPainter {
  final bool needsRepaint, isInBoundary;
  final Offset offset;
  singleAxisPainter(this.needsRepaint, this.offset, this.isInBoundary);
  @override
  void paint(Canvas canvas, Size size) {
    if (needsRepaint && isInBoundary) {
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Offset(this.offset.dx - 7.5, this.offset.dy - 12.5) &
                Size(15.0, 25.0),
            topRight: Radius.circular(3),
            bottomRight: Radius.circular(3),
            topLeft: Radius.circular(3),
            bottomLeft: Radius.circular(3),
          ),
          Paint()..color = Colors.cyan.shade200.withOpacity(0.6));
      canvas.drawRRect(
          RRect.fromRectAndCorners(
              Offset(this.offset.dx - 7.5, this.offset.dy - 12.5) &
                  Size(15.0, 25.0),
              topRight: Radius.circular(3),
              bottomRight: Radius.circular(3),
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3)),
          Paint()
            ..color = Colors.cyan.shade500.withOpacity(0.6)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Offset(-50, -12.5) & Size(100.0, 25.0),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          Paint()..color = Colors.blueGrey.shade600.withOpacity(0.6));
      canvas.drawRRect(
          RRect.fromRectAndCorners(Offset(-50, -12.5) & Size(100.0, 25.0),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10)),
          Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (needsRepaint && isInBoundary) ? true : false;
  }
}

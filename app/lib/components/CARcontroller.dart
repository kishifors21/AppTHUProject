import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import "dart:math" show pi;
import 'package:flutter/foundation.dart';
import 'package:app/globals.dart' as globals;

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

// ignore: must_be_immutable
class movePosition extends StatefulWidget {
  var top,
      bottom,
      height,
      width,
      right,
      left,
      icon,
      joystickFunc,
      sliderFunc,
      inkColor,
      buttonColor;
  movePosition(
      {this.top,
      this.bottom = 50,
      this.height = 100,
      this.width = 100,
      this.right = 30,
      this.left,
      this.joystickFunc,
      this.sliderFunc,
      this.inkColor = Colors.lightBlue,
      this.buttonColor = Colors.white});
  @override
  _movePosition createState() => _movePosition();
}

class _movePosition extends State<movePosition> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new Positioned(
          bottom: 50,
          height: 100,
          width: 100,
          left: 30,
          child: JoyStick(func: widget.joystickFunc),
        ),
        new Positioned(
          bottom: 50,
          right: 30,
          height: 100,
          width: 100,
          child: singleAxisJoyStick(func: widget.sliderFunc),
        ),
      ],
    );
  }
}

wheelFunc(speed, direction, turn, last_wheels, uri_ip) {
  // ignore: unused_local_variable
  // get four wheels' each pwm from speed(sp) and direction(dir)
  // sp: sp is from the distance of joystick to middle.
  //    sp's range is from 0 to 4095, which is also pwms' range.
  // dir: dirction is from joystick's angle.
  // direction's range is from -pi to pi. (left is about 3.14 or -3.14, up is about 1.57, and so on)
  //
  //
  Map wheels = {'lf': 0.0, 'rf': 0.0, 'lb': 0.0, 'rb': 0.0};
  if (speed == 0) {
    wheels = {
      'lf': 0.0,
      'rf': 0.0,
      'lb': 0.0,
      'rb': 0.0,
    };
  } else if (direction.abs == pi / 2) {
    wheels = {
      'lf': speed,
      'rf': speed,
      'lb': speed,
      'rb': speed,
    };
  } else if (direction == 0 || direction.abs == pi) {
    wheels = {
      'lf': -speed,
      'rf': speed,
      'lb': speed,
      'rb': -speed,
    };
    // 2nd Quadrant
  } else if (pi / 2 <= direction) {
    wheels = {
      'lf': -((direction - pi / 4 * 3) / pi * 4) * speed,
      'rf': speed,
      'lb': speed,
      'rb': -((direction - pi / 4 * 3) / pi * 4) * speed,
    };
    // 1st Quadrant
  } else if (pi / 2 > direction && direction >= 0) {
    wheels = {
      'lf': speed,
      'rf': ((direction - pi / 4) / pi * 4) * speed,
      'lb': ((direction - pi / 4) / pi * 4) * speed,
      'rb': speed,
    };
    // 4th Quadrant
  } else if (-pi / 2 <= direction && direction <= 0) {
    wheels = {
      'lf': ((direction + pi / 4) / pi * 4) * speed,
      'rf': -speed,
      'lb': -speed,
      'rb': ((direction + pi / 4) / pi * 4) * speed,
    };
    // 3rd Quadrant
  } else if (-pi / 2 >= direction) {
    wheels = {
      'lf': -speed,
      'rf': -((direction + pi / 4 * 3) / pi * 4) * speed,
      'lb': -((direction + pi / 4 * 3) / pi * 4) * speed,
      'rb': -speed,
    };
  }
  // print(wheels['lf']);
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
  if (!mapEquals(wheels, last_wheels)) {
    try {
      http.post(Uri.parse(uri_ip + 'wheels'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(wheels));
      last_wheels = wheels;
      return last_wheels;
    } catch (e) {}
  }
}

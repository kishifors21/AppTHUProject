import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

import 'package:app/my_flutter_app_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  Future fetchVolt() async {
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
      print(e);
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

  void wheelsTimer() {
    if (x > 0) {
    } else if (x < 0) {
    } else {
      setState(() {
        wheels = jsonEncode({'lf': y, 'rf': y, 'lb': y, 'rb': y});
      });
    }
    http.post(
      Uri.parse(uri_ip + 'wheels'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'start': 'begin', 'test': 1}),
    );
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      try {
        http.post(
          Uri.parse(uri_ip + 'wheels'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: wheels,
        );
      } catch (e) {}
      // fetchVolt().then((value) => setState(() {
      //       _volt = value;
      //       // print(value);
      //     }));
      // print(timer.tick);
    });
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }
  bool islive = true;
  bool isChargeToggle = true, isTrackerToggle = true;
  late var wheels;
  // String uri_ip = 'http://192.168.1.1:8080/';
  late String uriVideo;
  String uri_ip = 'http://192.168.1.1:8080/';
  String _volt = "-1";
  var x = 0, y = 0, turn = 0;

  void initState() {
    uriVideo = uri_ip + 'video_feed';
    wheels = jsonEncode({'lf': 0, 'rf': 0, 'lb': 0, 'rb': 0});
    super.initState();
    voltTimer();
    // wheelsTimer();
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
                  print(error);
                  print(stack);

                  return Text(error.toString(),
                      style: TextStyle(color: Colors.red));
                },
                stream:
                    // 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER',
                    // 'http://172.24.8.23:8080/video_feed',
                    uriVideo,
              ),
              // Text(
              //   '$_volt',
              //   style: Theme.of(context).textTheme.headline4,
              // ),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headline4,
              // ),
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
        new Positioned(
          bottom: 50,
          height: 100,
          width: 100,
          left: 30,
          child: JoyStick(func: (var dx, var dy) {
            setState(() {
              x = dx;
              y = dy;
            });
          }),
        ),
        new Positioned(
          bottom: 50,
          right: 30,
          height: 100,
          width: 100,
          child: singleAxisJoyStick(func: (var dx) {
            setState(() {
              turn = dx;
            });
          }),
        ),
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
              print(e);
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
              isTrackerToggle == true
                  ? await http.get(Uri.parse(uri_ip + '?method=re'))
                  : await http.get(Uri.parse(uri_ip + '?method=re stop'));
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
              await http.get(Uri.parse(uri_ip + '?method=shoot'));
            } catch (e) {
              print(e);
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
              await Future.delayed(Duration(seconds: 1));
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
          // color: Colors.lightBlue,
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
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
          },
          onPanUpdate: (details) {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset tmpOfsset = renderBox!.globalToLocal(details.globalPosition);
            tmpOfsset = Offset(tmpOfsset.dx - 50, tmpOfsset.dy - 50);

            if (tmpOfsset.distance < 50) {
              // if (smallCircleOffset.distance < 50) {
              setState(() {
                smallCircleOffset = tmpOfsset;
                widget.func(tmpOfsset.dx, tmpOfsset.dy);
              });
            } else {
              setState(() {
                smallCircleOffset = Offset(
                    tmpOfsset.dx * 50 / tmpOfsset.distance,
                    tmpOfsset.dy * 50 / tmpOfsset.distance);
              });
              widget.func(tmpOfsset.dx * 50 / tmpOfsset.distance,
                  tmpOfsset.dy * 50 / tmpOfsset.distance);
            }
            // setState(
            //   () {
            //     RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            //     smallCircleOffset =
            //         renderBox!.globalToLocal(details.globalPosition);
            //   },
            // );
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
      // print(
      //     "Offset for smaller circle  = $offset with distance squared = ${offset.distanceSquared} \n and distance = ${offset.distance}\n direction:${offset.direction}");
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
      canvas.drawCircle(
          this.offset,
          50,
          Paint()
            // ..blendMode = BlendMode.overlay
            ..color = Colors.blueGrey.shade600.withOpacity(0.5));
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
          // color: Colors.lightBlue,
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
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
          },
          onPanUpdate: (details) {
            RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            Offset tmpOfsset = renderBox!.globalToLocal(details.globalPosition);
            tmpOfsset = Offset(tmpOfsset.dx - 50, tmpOfsset.dy - 50);

            if (tmpOfsset.distance < 50) {
              // if (smallCircleOffset.distance < 50) {
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
            // setState(
            //   () {
            //     RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            //     smallCircleOffset =
            //         renderBox!.globalToLocal(details.globalPosition);
            //   },
            // );
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
      // print(
      //     "Offset for smaller circle  = $offset with distance squared = ${offset.distanceSquared} \n and distance = ${offset.distance}\n direction:${offset.direction}");
      // canvas.drawCircle(this.offset, 20,
      //     Paint()..color = Colors.cyan.shade200.withOpacity(0.7));
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
      // canvas.drawCircle(this.offset, 50, Paint()..color = Colors.grey);
      // canvas.drawLine(
      //     Offset(-50, 0),
      //     Offset(50, 0),
      //     Paint()
      //       ..color = Colors.grey.withOpacity(0.5)
      //       ..strokeWidth = 20);
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

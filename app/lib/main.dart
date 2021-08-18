import 'dart:async';

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
  bool islive = true;
  bool isChargeToggle = true, isTrackerToggle = true;
  String uriVideo = 'http://172.24.8.23:8080/video_feed';
  String _volt = "-1";
  Future fetchVolt() async {
    try {
      final response =
          await http.get(Uri.parse('http://172.24.8.23:8080/volt'));

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

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  void initState() {
    super.initState();
    voltTimer();
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
                stream:
                    // 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER',
                    // 'http://172.24.8.23:8080/video_feed',
                    uriVideo,
                error: (context, error, stack) {
                  print(error);
                  print(stack);
                  return Text(error.toString(),
                      style: TextStyle(color: Colors.red));
                },
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
          top: 50,
          left: 0,
          child: Text(
            'Volt: $_volt',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 17),
          ),
        ),
        new Positioned(
          bottom: 50,
          height: 100,
          width: 100,
          left: 30,
          child: JoyStick(),
        ),
        new Positioned(
          bottom: 50,
          right: 30,
          height: 100,
          width: 100,
          child: singleAxisJoyStick(),
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
                  ? await http
                      .post(Uri.parse('http://172.24.8.23:8080/?method=re'))
                  : await http.post(
                      Uri.parse('http://172.24.8.23:8080/?method=re stop'));
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
                  ? await http
                      .post(Uri.parse('http://172.24.8.23:8080/?method=re'))
                  : await http.post(
                      Uri.parse('http://172.24.8.23:8080/?method=re stop'));
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
              await http
                  .post(Uri.parse('http://172.24.8.23:8080/?method=shoot'));
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
                uriVideo = uriVideo == 'http://172.24.8.23:8080/video_feed'
                    ? 'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER'
                    : 'http://172.24.8.23:8080/video_feed';
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

class JoyStick extends StatefulWidget {
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
              });
            } else {
              setState(() {
                smallCircleOffset = Offset(
                    tmpOfsset.dx * 50 / tmpOfsset.distance,
                    tmpOfsset.dy * 50 / tmpOfsset.distance);
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

class Painter extends CustomPainter {
  final bool needsRepaint, isInBoundary;
  final Offset offset;
  Painter(this.needsRepaint, this.offset, this.isInBoundary);
  @override
  void paint(Canvas canvas, Size size) {
    if (needsRepaint && isInBoundary) {
      // print(
      //     "Offset for smaller circle  = $offset with distance squared = ${offset.distanceSquared} \n and distance = ${offset.distance}\n direction:${offset.direction}");
      canvas.drawCircle(this.offset, 20, Paint()..color = Colors.amber);
    } else {
      // canvas.drawLine(
      //     Offset(0, 50),
      //     Offset(50, 50),
      //     Paint()
      //       ..color = Colors.grey
      //       ..strokeWidth = 20);
      canvas.drawCircle(this.offset, 50, Paint()..color = Colors.grey);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (needsRepaint && isInBoundary) ? true : false;
  }
}

class singleAxisJoyStick extends StatefulWidget {
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
      canvas.drawCircle(this.offset, 20, Paint()..color = Colors.amber);
    } else {
      // canvas.drawCircle(this.offset, 50, Paint()..color = Colors.grey);
      canvas.drawLine(
          Offset(-50, 0),
          Offset(50, 0),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 20);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (needsRepaint && isInBoundary) ? true : false;
  }
}

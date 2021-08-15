import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;

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
  int _counter = 0;
  String _volt = "-1";
  Future fetchVolt() async {
    final response = await http.get(Uri.parse('http://172.24.8.23:8080/volt'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
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
    // voltTimer();
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
                stream:
                    'http://91.133.85.170:8090/cgi-bin/faststream.jpg?stream=half&fps=15&rand=COUNTER',
                // 'http://172.24.8.23:8080/video_feed',
                error: (context, error, stack) {
                  print(error);
                  print(stack);
                  return Text(error.toString(),
                      style: TextStyle(color: Colors.red));
                },
              ),
              Text(
                '$_volt',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        new Positioned(
          bottom: 50,
          height: 100,
          width: 100,
          left: 100,
          child: JoyStick(),
        )
      ],
    );
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }
}
// class moveButton extends StatefulWidget {
//   @override
//   _moveButtonState createState() => _moveButtonState();
// }

// class _moveButtonState extends State<moveButton> {
//   @override
//   Color _color = Colors.white;
//   bool isRunning = true;
//   Widget build(BuildContext context) {
//     return SliverGrid(
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 200.0,
//         mainAxisSpacing: 10.0,
//         crossAxisSpacing: 10.0,
//         childAspectRatio: 4.0,
//       ),
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           return Container(
//             color: _color,
//             height: 50.0,
//             width: 50.0,
//             child: GestureDetector(
//               onTapDown: (TapDownDetails details) {
//                 setState(() {
//                   _color = Colors.yellow;
//                 });
//               },
//               onTapUp: (TapUpDetails details) {
//                 setState(() {
//                   _color = Colors.blue;
//                 });
//               },
//               onTapCancel: () {
//                 setState(() {
//                   _color = Colors.white;
//                 });
//               },
//             ),
//           );
//         },
//         childCount: 20,
//       ),
//     );
//   }
// }

class JoyStick extends StatefulWidget {
  @override
  _JoyStickState createState() => _JoyStickState();
}

class _JoyStickState extends State<JoyStick> {
  late Offset offset, smallCircleOffset;
  @override
  void initState() {
    offset = Offset(50, 50);
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
          color: Colors.lightBlue,
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
        ),
        CustomPaint(
          painter: Painter(false, this.offset, false),
          child: CustomPaint(
            painter: Painter(true, smallCircleOffset, (true)),
          ),
        ),
        GestureDetector(
          onPanEnd: (details) {
            setState(() {
              smallCircleOffset = offset;
            });
          },
          onPanUpdate: (details) {
            if (Offset(smallCircleOffset.dx - 50, smallCircleOffset.dy - 50)
                    .distance <
                50) {
              // if (smallCircleOffset.distance < 50) {
              setState(() {
                RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                smallCircleOffset =
                    renderBox!.globalToLocal(details.globalPosition);
              });
            } else {
              setState(() {
                RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                smallCircleOffset =
                    renderBox!.globalToLocal(details.globalPosition);
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
      print(
          "Offset for smaller circle  = $offset with distance squared = ${offset.distanceSquared} \n and distance = ${offset.distance}\n direction:${offset.direction}");
      canvas.drawCircle(this.offset, 20, Paint()..color = Colors.amber);
    } else {
      canvas.drawCircle(this.offset, 50, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (needsRepaint && isInBoundary) ? true : false;
  }
}

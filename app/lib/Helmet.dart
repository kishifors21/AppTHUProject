import 'package:flutter/material.dart';

import 'package:app/components/common.dart';
import 'package:app/components/helmet_component.dart';

class HelmetApp extends StatefulWidget {
  HelmetApp();

  @override
  _HelmetAppState createState() => _HelmetAppState();
}

class _HelmetAppState extends State<HelmetApp> {
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        commonPage(pageType: 'video_feed'),
        helemetwidget(),
      ],
    );
  }
}

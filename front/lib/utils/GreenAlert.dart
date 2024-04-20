import 'dart:html';

import 'package:flutter/material.dart';

class GreenAlert extends StatefulWidget {
  final String message;
  final double width;

  const GreenAlert({Key? key, required this.message, required this.width}) : super(key: key);

  @override
  _GreenAlertState createState() => _GreenAlertState();
}

class _GreenAlertState extends State<GreenAlert> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    child = Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Text(
        widget.message,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
    // After 5 seconds, hide the alert
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  Widget child = Container();

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: () {
        setState(() {
          child = Container();
        });
      },
      child: child,
    );
  }
}
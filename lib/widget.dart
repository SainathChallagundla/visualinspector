import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  Loader();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Center(child: CircularProgressIndicator())),
    );
  }
}

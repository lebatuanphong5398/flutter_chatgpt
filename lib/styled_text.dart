import 'package:flutter/material.dart';

class StyleTexxt extends StatelessWidget {
  const StyleTexxt(this.text, {super.key});
  final String text;

  @override
  Widget build(context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 28),
    );
  }
}

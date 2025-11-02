import 'package:flutter/material.dart';

InputDecoration customInputDecoration(BuildContext context) {
  final brightness = Theme.of(context).brightness;

  return InputDecoration(
    border: InputBorder.none,
    fillColor:
        brightness == Brightness.dark ? Colors.grey[800] : Colors.green[50],
    filled: true,
  );
}

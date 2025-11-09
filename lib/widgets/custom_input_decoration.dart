import 'package:flutter/material.dart';

InputDecoration customInputDecoration(BuildContext context) {
  return InputDecoration(
    border: InputBorder.none,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    filled: true,
  );
}

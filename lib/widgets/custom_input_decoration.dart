import 'package:flutter/material.dart';
import '../config/decorations.dart';

InputDecoration customInputDecoration(BuildContext context) {
  return InputDecoration(
    border: InputBorder.none,
    fillColor: AppColors.inputBackground(context),
    filled: true,
  );
}

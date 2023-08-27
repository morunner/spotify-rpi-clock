import 'package:flutter/material.dart';

class MyColorScheme {
  static const Color darkGreen = Color(0xFF213438);
  static const Color white = Color(0xFFFFF8F0);
  static const Color red = Color(0xFF9E2B25);
  static const Color yellow = Color(0xFFE29837);
}

class MainAppBarStyle {
  static const double height = 1.4 * kToolbarHeight;
  static const Color navigationButtonColor = MyColorScheme.yellow;
  static const Color titleColor = MyColorScheme.white;
  static const double navigationButtonTextSize = 16;
  static const double navigationButtonIconSize = 20;
}

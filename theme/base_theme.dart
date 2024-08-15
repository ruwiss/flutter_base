import 'package:flutter/material.dart';

abstract class BaseTheme {
  Brightness get brightness;
  ColorScheme get colorScheme;

  ThemeData get theme {
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      typography: Typography.material2021(),
    );
  }
}

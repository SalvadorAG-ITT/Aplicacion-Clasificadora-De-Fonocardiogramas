import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Inter';

  static const TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 20.0,
      fontWeight: FontWeight.w900,
    ),
    bodyMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 32.0,
      fontWeight: FontWeight.w500,
    ),
  );
}

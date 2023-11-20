import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE4F2F3),
  100: Color(0xFFBCDFE0),
  200: Color(0xFF8FC9CC),
  300: Color(0xFF62B3B7),
  400: Color(0xFF40A3A7),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF1A8B90),
  700: Color(0xFF168085),
  800: Color(0xFF12767B),
  900: Color(0xFF0A646A),
});

const int _primaryPrimaryValue = 0xFF1E9398;

const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF9CF8FF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF36F1FF),
  700: Color(0xFF1CEFFF),
});
const int _primaryAccentValue = 0xFF69F5FF;
import 'package:flutter/material.dart';

ThemeData customTheme() {
  return ThemeData(
    fontFamily: "Montserrat",
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: "Montserrat",
      ),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.red,
    ),
    primarySwatch: Colors.blue,
  );
}

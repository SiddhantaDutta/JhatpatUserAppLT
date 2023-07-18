import 'package:flutter/material.dart';

var bottomSheetTopShadow = const BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
  boxShadow: <BoxShadow>[
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0.0, -2.0),
      blurRadius: 8.0,
      spreadRadius: 2.0,
    )
  ],
);

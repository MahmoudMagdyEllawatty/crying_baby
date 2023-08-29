import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class TabSettings extends StatefulWidget {
  @override
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {


  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: Container(
        // homex8o (1:67)
        width: double.infinity,
        height: 812*fem,
        child: Stack(
          children: [

          ],
        ),
      ),
    );
  }
}
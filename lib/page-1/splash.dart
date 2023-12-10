import 'dart:convert';

import 'package:CryingBaby/page-1/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show Platform;
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

import '../utils.dart';

class Splash extends StatefulWidget {
  @override
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<Splash> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );

    });



  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.fromLTRB(20, 100, 20, 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0,50,0,0),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 200,
                width: 200,

              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Center(
              child: Text(AppLocalizations.of(context)!.app_name,style: SafeGoogleFont (
                'Roboto',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              )),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
            child: Center(
              child: Text(AppLocalizations.of(context)!.splash_text,style: SafeGoogleFont (
                'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              )),
            ),
          ),


         
        ],
      ),
    );
  }

}
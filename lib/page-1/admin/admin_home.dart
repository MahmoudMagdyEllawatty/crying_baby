import 'dart:async';
import 'dart:io';

import 'package:CryingBaby/colors.dart';
import 'package:CryingBaby/page-1/add_request.dart';
import 'package:CryingBaby/page-1/admin/advices.dart';
import 'package:CryingBaby/page-1/admin/notifications.dart';
import 'package:CryingBaby/page-1/admin/vaccines_list.dart';
import 'package:CryingBaby/page-1/not_yet.dart';
import 'package:CryingBaby/page-1/profile.dart';
import 'package:CryingBaby/page-1/requests.dart';
import 'package:CryingBaby/page-1/statics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:CryingBaby/page-1/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_scanning.dart';
import '../login.dart';
import '../user/questions_list.dart';


class AdminHome extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<AdminHome> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int currentIndex = 0;
  List<String> pages = ["",""];

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
    setState(() {
      pages =[
        AppLocalizations.of(context)!.vaccine,
        AppLocalizations.of(context)!.notifications,
        AppLocalizations.of(context)!.advices,
        AppLocalizations.of(context)!.questions
      ];
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[currentIndex]),
        centerTitle: false,
        actions: <Widget>[

          IconButton(
            tooltip: 'Bluetooth ON',
            icon: Icon(Icons.logout),
            onPressed: () async{
              final SharedPreferences prefs = await _prefs;
              prefs.setString("phone", "");
              prefs.setString("password", "");

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false,
              );
            },
            color: Colors.white,
          )
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          TabVaccines(),
          TabNotifications(),
          TabAdvices(),
          TabQuestions(),
        ],
      ),
      bottomNavigationBar:
      Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.white,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.red,
            textTheme: Theme
                .of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });

            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.medication_liquid),
                label: AppLocalizations.of(context)!.vaccine,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: AppLocalizations.of(context)!.notifications,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined),
                label: AppLocalizations.of(context)!.advices,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.question_mark),
                label: AppLocalizations.of(context)!.questions,
              ),
            ]
        ),
      ),
    );
  }

  handleOpenLocationSettings() async {
    if (Platform.isAndroid) {
      await flutterBeacon.openLocationSettings;
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Services Off'),
            content: Text(
              'Please enable Location Services on Settings > Privacy > Location Services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  handleOpenBluetooth() async {
    if (Platform.isAndroid) {
      try {
        await flutterBeacon.openBluetoothSettings;
      } on PlatformException catch (e) {
        print(e);
      }
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bluetooth is Off'),
            content: Text('Please enable Bluetooth on Settings > Bluetooth.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
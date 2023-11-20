import 'dart:async';
import 'dart:io';

import 'package:CryingBaby/colors.dart';
import 'package:CryingBaby/page-1/add_request.dart';
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

import '../controller/requirement_state_controller.dart';
import '../model/SharedData.dart';
import 'app_broadcasting.dart';
import 'app_scanning.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final controller = Get.find<RequirementStateController>();
  StreamSubscription<BluetoothState>? _streamBluetooth;
  int currentIndex = 0;
  List<String> pages = ["",""];

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);

    super.initState();

    listeningState();

    requestPermission();
  }

  void requestPermission() async{


    Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan,Permission.notification,
      Permission.location].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.notification] == PermissionStatus.granted &&
        statuses[Permission.location] == PermissionStatus.granted) {
      // permission granted
    }
  }

  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      controller.updateBluetoothState(state);
      await checkAllRequirements();
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    controller.updateBluetoothState(bluetoothState);
    print('BLUETOOTH $bluetoothState');

    final authorizationStatus = await flutterBeacon.authorizationStatus;
    controller.updateAuthorizationStatus(authorizationStatus);
    print('AUTHORIZATION $authorizationStatus');

    final locationServiceEnabled =
    await flutterBeacon.checkLocationServicesIfEnabled;
    controller.updateLocationService(locationServiceEnabled);
    print('LOCATION SERVICE $locationServiceEnabled');

    if (controller.bluetoothEnabled &&
        controller.authorizationStatusOk &&
        controller.locationServiceEnabled) {
      print('STATE READY');
      if (currentIndex == 0) {
        print('SCANNING');
        controller.startScanning();
      } else {
        print('BROADCASTING');
        controller.startBroadcasting();
      }
    } else {
      print('STATE NOT READY');
      controller.pauseScanning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null) {
        if (_streamBluetooth!.isPaused) {
          _streamBluetooth?.resume();
        }
      }
      await checkAllRequirements();
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    _streamBluetooth?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      pages =[
        AppLocalizations.of(context)!.home,
        AppLocalizations.of(context)!.statics,
        AppLocalizations.of(context)!.vacation,
        AppLocalizations.of(context)!.orders,
        AppLocalizations.of(context)!.profile
      ];
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[currentIndex]),
        centerTitle: false,
        actions: <Widget>[
          Visibility(
            visible: false,
            child: Obx(() {
              if (!controller.locationServiceEnabled)
                return IconButton(
                  tooltip: 'Not Determined',
                  icon: Icon(Icons.portable_wifi_off),
                  color: Colors.grey,
                  onPressed: () {},
                );

              if (!controller.authorizationStatusOk)
                return IconButton(
                  tooltip: 'Not Authorized',
                  icon: Icon(Icons.portable_wifi_off),
                  color: Colors.red,
                  onPressed: () async {
                    await flutterBeacon.requestAuthorization;
                  },
                );

              return IconButton(
                tooltip: 'Authorized',
                icon: Icon(Icons.wifi_tethering),
                color: Colors.blue,
                onPressed: () async {
                  await flutterBeacon.requestAuthorization;
                },
              );
            }),
          ),
          Visibility(
            visible: false,
            child: Obx(() {
              return IconButton(
                tooltip: controller.locationServiceEnabled
                    ? 'Location Service ON'
                    : 'Location Service OFF',
                icon: Icon(
                  controller.locationServiceEnabled
                      ? Icons.location_on
                      : Icons.location_off,
                ),
                color:
                controller.locationServiceEnabled ? Colors.blue : Colors.red,
                onPressed: controller.locationServiceEnabled
                    ? () {}
                    : handleOpenLocationSettings,
              );
            }),
          ),
          Visibility(
            visible: false,
            child: Obx(() {
              final state = controller.bluetoothState.value;

              if (state == BluetoothState.stateOn) {
                return IconButton(
                  tooltip: 'Bluetooth ON',
                  icon: Icon(Icons.bluetooth_connected),
                  onPressed: () {},
                  color: Colors.lightBlueAccent,
                );
              }

              if (state == BluetoothState.stateOff) {
                return IconButton(
                  tooltip: 'Bluetooth OFF',
                  icon: Icon(Icons.bluetooth),
                  onPressed: handleOpenBluetooth,
                  color: Colors.red,
                );
              }

              return IconButton(
                icon: Icon(Icons.bluetooth_disabled),
                tooltip: 'Bluetooth State Unknown',
                onPressed: () {},
                color: Colors.grey,
              );
            }),
          ),
          IconButton(
            tooltip: 'Bluetooth ON',
            icon: Icon(Icons.notifications),
            onPressed: () {

            },
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Bluetooth ON',
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TabSettings()),
              );
            },
            color: Colors.white,
          ),
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
          TabScanning(),
          TabStatics(),
          TabAddRequest(),
          TabRequests(),
          TabProfile(),
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

            if (currentIndex == 0) {
              controller.startScanning();
            } else {
              controller.pauseScanning();
            }




              if(currentIndex == 2){
                setState(() {
                  SharedData.type = -1;
                });
              }



          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: AppLocalizations.of(context)!.statics,
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/bar_add.png')),
              label: AppLocalizations.of(context)!.vacation,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_copy_sharp),
              label: AppLocalizations.of(context)!.orders,
            ),BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
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
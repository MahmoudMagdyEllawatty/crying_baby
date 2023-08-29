import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class TabScanning extends StatefulWidget {
  @override
  _TabScanningState createState() => _TabScanningState();
}

class _TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();

  List<Device> devices = [];
  List<WorkingHour> workingHours = [];
  List<Attendance> attendance = [];



  @override
  void initState() {
    super.initState();

    loadDevices();
    loadWorkingHours();
    getUserTodayData();

    controller.startStream.listen((flag) {
      if (flag == true) {
        initScanBeacon();
      }
    });

    controller.pauseStream.listen((flag) {
      if (flag == true) {
        pauseScanBeacon();
      }
    });
  }

  //region parsing
  List<Device> parseDevices(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<Device>((json)=>Device.fromJson(json)).toList();
  }

  List<WorkingHour> parseWorking(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<WorkingHour>((json)=>WorkingHour.fromJson(json)).toList();
  }

  List<Attendance> parseAttendance(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<Attendance>((json)=>Attendance.fromJson(json)).toList();
  }

  //endregion

  //region fetchingData
  Future<String> loadDevices() async {
    final response = await http.get(
        Uri.parse(SharedData.API_URL+"/devices"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"}
    );
    if(response.statusCode == 200){
      setState(() {
        devices = parseDevices(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      throw Exception('Cannot Save User');
    }
  }

  Future<String> loadWorkingHours() async {
    final response = await http.get(
        Uri.parse(SharedData.API_URL+"/working_hours"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"}
    );
    if(response.statusCode == 200){
      setState(() {
        workingHours = parseWorking(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      throw Exception('Cannot Save User');
    }
  }

  Future<String> getUserTodayData() async{
    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/today_data"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
        })
    );
    if(response.statusCode == 200){
      setState(() {
        attendance = parseAttendance(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      throw Exception('Cannot Save User');
    }
  }

  //endregion

  //region attendance

  Future<String> checkIn(String device) async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/check_in"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "device" : device
        })
    );
    if(response.statusCode == 200){

      setState(() {
        attendance = parseAttendance(response.body);
      });
      return "Done";


    }else{
      throw Exception('Cannot Save User');
    }
  }

  Future<String> checkOut(String device) async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/check_out"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "device" : device
        })
    );
    if(response.statusCode == 200){

      setState(() {
        attendance = parseAttendance(response.body);
      });
      return "Done";


    }else{
      throw Exception('Cannot Save User');
    }
  }

  String checkDeviceExist(){
    for(int i =0;i< devices.length;i++){
      if(isDeviceExist(devices[i].device_mac)){
        return devices[i].device_mac;
      }
    }
    return "";
  }

  bool isDeviceExist(String mac){
    for(int i =0;i < _beacons.length;i++){
      if(_beacons[i].macAddress!.replaceAll(":", "") == mac){
        return true;
      }
    }
    return false;
  }

  //endregion


  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    if (!controller.authorizationStatusOk ||
        !controller.locationServiceEnabled ||
        !controller.bluetoothEnabled) {
      print(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
              'locationServiceEnabled=${controller.locationServiceEnabled}, '
              'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {

          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;
              _beacons.clear();
              _regionBeacons.values.forEach((list) {
                _beacons.addAll(list);
              });
              _beacons.sort(_compareParameters);
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
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
            Positioned(
              // iphonexxs86F1 (1:68)
              left: 0*fem,
              top: 0*fem,
              child: Container(
                width: 375*fem,
                height: 812*fem,
                decoration: BoxDecoration (
                  image: DecorationImage (
                    fit: BoxFit.cover,
                    image: AssetImage (
                      'assets/page-1/images/vector-ZPV.png',
                    ),
                  ),
                ),
                child: Container(
                  // rectangle25bBm (1:70)
                  padding: EdgeInsets.fromLTRB(30*fem, 194*fem, 30*fem, 303*fem),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration (
                    color: Color(0xffe8e8e8),
                  ),
                  child: Container(
                    // autogroup92zmuTM (M89Q7QueNFsyFsaJaC92ZM)
                    padding: EdgeInsets.fromLTRB(16*fem, 38*fem, 25*fem, 156.94*fem),
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: attendance.isNotEmpty ? (attendance[0].attend_at != '') : false,
                          child: Container(
                            // groupDU3 (1:108)
                            margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 33.94*fem),
                            width: double.infinity,
                            height: 43.06*fem,
                            child: Text(
                              'Attend At :'+ (attendance.isNotEmpty? attendance[0].attend_at : ''),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ),
                        ),

                        Visibility(
                          visible: attendance.isNotEmpty ? (attendance[0].attend_at == '') : true,
                          child: Container(
                            // groupDU3 (1:108)
                            margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 33.94*fem),
                            width: double.infinity,
                            height: 43.06*fem,
                            decoration: BoxDecoration (
                              image: DecorationImage (
                                fit: BoxFit.cover,
                                image: AssetImage (
                                  'assets/page-1/images/login-button-shape.png',
                                ),
                              ),

                            ),
                            child: TextButton(
                              // buttonsVwM (1:110)
                              onPressed: () {
                                String macAddress =checkDeviceExist();
                                if(macAddress != ""){
                                  BuildContext dialogContext = context;
                                  showDialog(
                                    // The user CANNOT close this dialog  by pressing outsite it
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        dialogContext = context;
                                        return Dialog(
                                          // The background color
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                // The loading indicator
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                // Some text
                                                Text('Attending...')
                                              ],
                                            ),
                                          ),
                                        );
                                      });

                                  checkIn(macAddress).then((value){
                                    Navigator.pop(dialogContext);


                                  });
                                }
                                else{
                                  Fluttertoast.showToast(
                                      msg: "Devices Not Found!!!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                              },
                              style: TextButton.styleFrom (
                                padding: EdgeInsets.zero,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration (
                                  borderRadius: BorderRadius.circular(36.2043800354*fem),

                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      // ellipse1Cas (I1:110;6:493)
                                      left: 129.7591247559*fem,
                                      top: 18.3795166016*fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 7.24*fem,
                                          height: 7.24*fem,
                                          child: Container(
                                            decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(3.6204378605*fem),
                                              color: Color(0x00fbff48),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      // checkinVZy (1:111)
                                      left: 92*fem,
                                      top: 6*fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 94*fem,
                                          height: 30*fem,
                                          child: Text(
                                            'check in',
                                            style: SafeGoogleFont (
                                              'Roboto',
                                              fontSize: 25*ffem,
                                              fontWeight: FontWeight.w700,
                                              height: 1.1725*ffem/fem,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: attendance.isNotEmpty ? (attendance[0].leave_at != '') : false,
                          child: Container(
                            // groupDU3 (1:108)
                              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0*fem),
                              width: double.infinity,
                              height: 43.06*fem,
                              child: Text(
                                'Leave At :'+(attendance.isNotEmpty ? attendance[0].leave_at : ''),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                          ),
                        ),
                        Visibility(
                          visible: attendance.isNotEmpty ? (attendance[0].leave_at == '' && attendance[0].attend_at != '') : false,
                          child: Container(
                            // groupMs5 (1:116)
                            width: double.infinity,
                            height: 43.06*fem,
                            decoration: BoxDecoration (
                              image: DecorationImage (
                                fit: BoxFit.cover,
                                image: AssetImage (
                                  'assets/page-1/images/login-button-shape-Yx7.png',
                                ),
                              ),

                            ),
                            child: TextButton(
                              // buttons5YB (1:118)
                              onPressed: () {
                                String macAddress =checkDeviceExist();
                                if(macAddress != ""){
                                  BuildContext dialogContext = context;
                                  showDialog(
                                    // The user CANNOT close this dialog  by pressing outsite it
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        dialogContext = context;
                                        return Dialog(
                                          // The background color
                                          backgroundColor: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                // The loading indicator
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                // Some text
                                                Text('Attending...')
                                              ],
                                            ),
                                          ),
                                        );
                                      });

                                  checkOut(macAddress).then((value){
                                    Navigator.pop(dialogContext);


                                  });
                                }
                                else{
                                  Fluttertoast.showToast(
                                      msg: "Devices Not Found!!!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                              },
                              style: TextButton.styleFrom (
                                padding: EdgeInsets.zero,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration (
                                  borderRadius: BorderRadius.circular(36.2043800354*fem),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x21000000),
                                      offset: Offset(0*fem, 14.481751442*fem),
                                      blurRadius: 50.6861305237*fem,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      // ellipse1yNf (I1:118;6:493)
                                      left: 129.7591247559*fem,
                                      top: 18.3795623779*fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 7.24*fem,
                                          height: 7.24*fem,
                                          child: Container(
                                            decoration: BoxDecoration (
                                              borderRadius: BorderRadius.circular(3.6204378605*fem),
                                              color: Color(0x00fbff48),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      // checkoutgH5 (1:119)
                                      left: 79*fem,
                                      top: 5*fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 110*fem,
                                          height: 30*fem,
                                          child: Text(
                                            'check out',
                                            style: SafeGoogleFont (
                                              'Roboto',
                                              fontSize: 25*ffem,
                                              fontWeight: FontWeight.w700,
                                              height: 1.1725*ffem/fem,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // group13891Axw (1:96)
              left: 0.0000152588*fem,
              top: 745*fem,
              child: Container(
                width: 375*fem,
                height: 86.24*fem,
                child: Stack(
                  children: [
                    Positioned(
                      // group13888VVR (1:97)
                      left: 0*fem,
                      top: 0*fem,
                      child: Align(
                        child: SizedBox(
                          width: 375*fem,
                          height: 86.24*fem,
                          child: Image.asset(
                            'assets/page-1/images/group-13888.png',
                            width: 375*fem,
                            height: 86.24*fem,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      // homea15 (1:106)
                      left: 165.2256317139*fem,
                      top: 46.9999389648*fem,
                      child: Align(
                        child: SizedBox(
                          width: 39*fem,
                          height: 13*fem,
                          child: Text(
                            'Home',
                            textAlign: TextAlign.right,
                            style: SafeGoogleFont (
                              'Poppins',
                              fontSize: 12.6000013351*ffem,
                              fontWeight: FontWeight.w400,
                              height: 1*ffem/fem,
                              letterSpacing: 0.2700000703*fem,
                              color: Color(0xffe54476),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
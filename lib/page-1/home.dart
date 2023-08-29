import 'dart:convert';

import 'package:attendance_app/model/WorkingHour.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../utils.dart';

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }

}

class _HomeState extends State<Home>  with WidgetsBindingObserver{

  List<Device> devices = [];
  List<WorkingHour> workingHours = [];
  List<Attendance> attendance = [];



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadDevices();
    loadWorkingHours();
    getUserTodayData();


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

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: Container(
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
                              onPressed: () {},
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
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x29000000),
                                  offset: Offset(0*fem, 3*fem),
                                  blurRadius: 3*fem,
                                ),
                              ],
                            ),
                            child: TextButton(
                              // buttons5YB (1:118)
                              onPressed: () {},
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
import 'dart:convert';

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import '../colors.dart';
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/Request.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import '../widget/CustomColorSelectionHandle.dart';

class TabRequests extends StatefulWidget {
  @override
  _TabRequests createState() => _TabRequests();
}

class _TabRequests extends State<TabRequests> {

  List<Request> _requests = [];
  List<String> states = [
    "في انتظار الرد",
    "مقبول",
    "مرفوض"
  ];

  List<Color?> stateColors = [
    Colors.grey,
    Colors.green,
    Colors.red
  ];


  List<String> types = [
    "طلب استئذان",
    "طلب أجازة",
    "طلب نسيان بصمة"
  ];

  @override
  void initState() {
    super.initState();
    if(!SharedData.orders_loaded){

      SharedData.orders_loaded = true;
    }

  }

  List<Request> parseMonthStatics(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<Request>((json)=>Request.fromJson(json)).toList();
  }

  Future<String> getRequests() async{
    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/get_requests"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,

        })
    );
    if(response.statusCode == 200){
      setState(() {
        _requests = parseMonthStatics(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      return "";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    getRequests();

    return Scaffold(

      body: SingleChildScrollView(

        child: Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Visibility(
                visible: true,
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        side: BorderSide(
                          // border color
                            color: primary,
                            // border thickness
                            width: 1)),
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Text("قائمة الطلبات",style: SafeGoogleFont (
                                    'Roboto',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1725,
                                    color: Color.fromARGB(255, 253, 163, 13),
                                  )),
                                ),
                          ],
                        ),

                        Divider(color: Colors.grey,),

                        ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _requests.length,
                            itemBuilder: (context,index) {
                              return Card(

                                color: Colors.white,
                                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          child: Text(types[int.parse(_requests[index].type)-1]  ,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1725,
                                            color: primary,
                                          )),
                                        ),
                                      ),

                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          child: Text(_requests[index].created_at ,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1725,
                                            color: primary,
                                          )),
                                        ),
                                      ),

                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          child: Text(states[int.parse(_requests[index].state)] ,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1725,
                                            color: stateColors[int.parse(_requests[index].state)],

                                          ),textAlign: TextAlign.left,),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              );
                            }),



                      ],
                    ),
                  )
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }

}
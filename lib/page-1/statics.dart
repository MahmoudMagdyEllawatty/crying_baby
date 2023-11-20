import 'dart:convert';

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:io' show Platform;
import '../colors.dart';
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class TabStatics extends StatefulWidget {
  @override
  _TabStaticsState createState() => _TabStaticsState();
}

class _TabStaticsState extends State<TabStatics> {

  List<String> months = [];
  MonthStatics monthStatics = MonthStatics("0", "0", "0", "0", "0","0","0");

  List<_ChartData> data = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();

  }

  List<MonthStatics> parseMonthStatics(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<MonthStatics>((json)=>MonthStatics.fromJson(json)).toList();
  }

  Future<String> getMonthStatics() async{
    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/month_statics"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
        })
    );
    if(response.statusCode == 200){
      setState(() {
        monthStatics = parseMonthStatics(response.body)[0];

        data.add(_ChartData("أيام العمل", double.parse(monthStatics.totalMonthDays)));
        data.add(_ChartData("الحضور", double.parse(monthStatics.totalAttendDays)));
        data.add(_ChartData("الغياب", double.parse(monthStatics.totalAbsenceDays)));
        data.add(_ChartData("الاسئذانات", double.parse(monthStatics.totalGoout)));
        data.add(_ChartData("الأجازات", double.parse(monthStatics.totalHolidays)));
        data.add(_ChartData("نسيان البصمة", double.parse(monthStatics.totalFingers)));

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

      getMonthStatics();


    months = [
      AppLocalizations.of(context)!.january,
      AppLocalizations.of(context)!.february,
      AppLocalizations.of(context)!.march,
      AppLocalizations.of(context)!.april,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.june,
      AppLocalizations.of(context)!.july,
      AppLocalizations.of(context)!.august,
      AppLocalizations.of(context)!.september,
      AppLocalizations.of(context)!.october,
      AppLocalizations.of(context)!.november,
      AppLocalizations.of(context)!.december
    ];
    return Scaffold(

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
                  child: Column(
                    children: [
                      Visibility(
                          visible: SharedData.attendance.isNotEmpty,
                          child: Column(
                            children: [
                              Container(
                                child:  Text(  SharedData.attendance.lastOrNull?.leave_at == "" ? "تسجيل حضور" : "تسجيل انصراف",style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                )),
                              ),
                              Container(
                                child:  Text( SharedData.attendance.lastOrNull?.leave_at == "" ?
                                (SharedData.attendance.length > 0 ? SharedData.attendance.last.attend_at : "") :
                                (SharedData.attendance.length > 0 ? SharedData.attendance.last.leave_at : "" )
                                    ,style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                )),
                              ),
                            ],
                          )
                      ),
                      Visibility(
                        visible: true,
                        child: Card(
                          elevation: 10,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              side: BorderSide(
                                // border color
                                  color: primary,
                                  // border thickness
                                  width: 1)),
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("احصائيات ("+months[DateTime.now().month-1]+")",style: SafeGoogleFont (
                                      'Roboto',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1725,
                                      color: Color.fromARGB(255, 253, 163, 13),
                                    )),
                                  ],
                                ),
                                Divider(color: Colors.grey,),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("أيام العمل",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalMonthDays,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text("الحضور",style: SafeGoogleFont (
                                                'Roboto',
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              )),
                                              Icon(Icons.trip_origin, color: Colors.green, size: 1,)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalAttendDays,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("الغياب",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalAbsenceDays,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("عدد ساعات التأخير",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalDelayHours,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("عدد الاستئذانات",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalGoout,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("عدد الأجازات",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalHolidays,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("عدد نسيان البصمة",style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(monthStatics.totalFingers,style: SafeGoogleFont (
                                            'Roboto',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: data.isNotEmpty,
                        child: Card(
                          child: Container(
                            child: Column(
                              children: [
                                SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(minimum: 0, maximum: 30, interval: 5),
                              tooltipBehavior: _tooltip,
                              series: <ChartSeries<_ChartData, String>>[
                                ColumnSeries<_ChartData, String>(
                                    dataSource: data,
                                    xValueMapper: (_ChartData data, _) => data.xAxis,
                                    yValueMapper: (_ChartData data, _) => data.yAxis,
                                    name: 'Gold',
                                    color: primary)
                              ])

                              ],
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

}

class _ChartData{
  _ChartData(this.xAxis,this.yAxis);

  final String xAxis;
  final double yAxis;
}
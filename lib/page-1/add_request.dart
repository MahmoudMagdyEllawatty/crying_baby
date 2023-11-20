import 'dart:convert';

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import '../colors.dart';
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import '../widget/CustomColorSelectionHandle.dart';

class TabAddRequest extends StatefulWidget {
  @override
  _TabAddRequestState createState() => _TabAddRequestState();
}

class _TabAddRequestState extends State<TabAddRequest> {

  var _dateController = TextEditingController();
  var _currentDateController = TextEditingController();
  var _fromDateController = TextEditingController();
  var _toDateController = TextEditingController();
  late SingleValueDropDownController _cnt;
  late SingleValueDropDownController _cnt2;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<WorkingHour> workingHours = [];
  List<Attendance> attendance = [];
  List<String> types = [
    "تسجيل حضور",
    "تسجيل انصراف"
  ];


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: SharedData.type < 3 ?  DateTime.now() : DateTime(2023),
        lastDate: SharedData.type < 3 ? DateTime(2101) : DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
        if(SharedData.type ==3){
          loadWorkingHours();
          getUserAttendance();
        }

      });
    }
  }

  Future<void> _selectTime(BuildContext context,int which) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedTime = picked;
        if(which == 1)
          _fromDateController.text = selectedTime.hour.toString()+":"+(selectedTime.minute.toString().length == 1 ?  "0"+selectedTime.minute.toString() : selectedTime.minute.toString());
        else
          _toDateController.text = selectedTime.hour.toString()+":"+(selectedTime.minute.toString().length == 1 ?  "0"+selectedTime.minute.toString() : selectedTime.minute.toString());
      });
    }
  }

  @override
  void initState() {
    _cnt = SingleValueDropDownController();
    _cnt2 = SingleValueDropDownController();
    super.initState();
    SharedData.type = -1;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    _currentDateController.text = formatter.format(now);

  }

  @override
  void dispose() {
    _cnt.dispose();
    _cnt2.dispose();
    super.dispose();
  }

  List<MonthStatics> parseMonthStatics(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<MonthStatics>((json)=>MonthStatics.fromJson(json)).toList();
  }

  Future<String> addRequest() async{

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/add_request"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "date" : _dateController.text.toString(),
          "from_date" : SharedData.type == 1 ?  _fromDateController.text.toString() : SharedData.type == 3 && _cnt2.dropDownValue!.value == 0 ? (_cnt.dropDownValue?.value) : "00:00",
          "to_date" : SharedData.type == 1 ?  _toDateController.text.toString() :  SharedData.type == 3 && _cnt2.dropDownValue!.value == 1 ? (_cnt.dropDownValue?.value) :  "23:59",
          "type" : SharedData.type
        })
    );
    if(response.statusCode == 200){

      _toDateController.text = "";
      _fromDateController.text = "";
      _dateController.text=  "";
      return "تم تسجيل الدخول بنجاح";
    }else{
      print(response.body);
      return "";
    }
  }


  List<WorkingHour> parseWorking(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<WorkingHour>((json)=>WorkingHour.fromJson(json)).toList();
  }

  Future<String> loadWorkingHours() async {
    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/day_working_hours"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "date" : _dateController.text.toString()
        })
    );
    if(response.statusCode == 200){
      setState(() {
        workingHours = parseWorking(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      return "";
    }
  }

  List<Attendance> parseAttendance(String responseBody){
    final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
    return parsed.map<Attendance>((json)=>Attendance.fromJson(json)).toList();
  }

  Future<String> getUserAttendance() async{
    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/get_user_attendance"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "date" : _dateController.text.toString()
        })
    );
    if(response.statusCode == 200){
      setState(() {
        attendance = parseAttendance(response.body);
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      print(response.body);
      return "";
    }
  }

  List<DropDownValueModel> items = [];
   DropDownItems(){
     List<DropDownValueModel> items1 = [];
     for(var i = 0; i < workingHours.length;i++){
       var element = workingHours[i];
        int selectedType = _cnt2.dropDownValue == null ? 0 : _cnt2.dropDownValue!.value;
       items1.add(DropDownValueModel(name:  "دوام من " +element.attend_time +" الي " + element.leave_time,
           value: selectedType == 0 ? element.attend_time : element.leave_time));
     }

     setState(() {
       items = items1;
     });
  }

  List<DropDownValueModel> DropDownItems2(){
    List<DropDownValueModel> items = [];
    for(var i = 0; i < types.length;i++){

      items.add(DropDownValueModel(name:types[i],
          value:i));
    }

    return items;
  }

  WorkingHour getWorkingHour(){
    for(int i =0;i < workingHours.length;i++){
      if(_cnt2.dropDownValue!.value == 0){
        if(workingHours[i].attend_time == _cnt.dropDownValue?.value){
          return workingHours[i];
        }
      }else{
        if(workingHours[i].leave_time == _cnt.dropDownValue?.value){
          return workingHours[i];
        }
      }

    }
    return new WorkingHour("", "", "");
  }

  Attendance checkIfAttendanceExist(WorkingHour workingHour){

    // if(attendance.length == 0){
    //   return new Attendance("", "", "1", "", "", "", "", "");
    // }

    for(int i =0;i< attendance.length;i++){
      if(attendance[i].actual_attend_at == workingHour.attend_time){
        return attendance[i];
      }
    }

    return new Attendance("", "", "", "", "", "", "", "");
  }

  @override
  Widget build(BuildContext context) {


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
                visible: SharedData.type == 1,
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
                                  child: Text("طلب استئذان",style: SafeGoogleFont (
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

                        Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text("تاريخ الطلب",style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                  decoration: TextDecoration.none
                              )),
                            ),
                        Container(
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Material(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                child: TextField(
                                  readOnly: true,
                                  selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                  keyboardType: TextInputType.text,
                                  controller: _currentDateController,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      hintText: "تاريخ الاستئذان"
                                  ) ,
                                  style: SafeGoogleFont (
                                    'Roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),

                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text("تاريخ الاستئذان",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                              color: primary,
                              decoration: TextDecoration.none
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: Material(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: TextField(
                              readOnly: true,
                              selectionControls: CustomColorSelectionHandle(Colors.transparent),
                              keyboardType: TextInputType.text,
                              controller: _dateController,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  hintText: "تاريخ الاستئذان"
                              ) ,
                              style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: primary,
                              ),
                              onTap: (){
                                _selectDate(context);
                              },
                            ),
                          ),
                        ),

                        Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text("وقت البداية",style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                  decoration: TextDecoration.none
                              )),
                            ),
                        Container(
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Material(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                child: TextField(
                                  readOnly: true,
                                  selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                  keyboardType: TextInputType.text,
                                  controller: _fromDateController,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      hintText: "وقت البداية"
                                  ) ,
                                  style: SafeGoogleFont (
                                    'Roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: primary,
                                  ),
                                  onTap: (){
                                    _selectTime(context,1);
                                  },
                                ),
                              ),
                            ),

                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text("وقت النهاية",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                              color: primary,
                              decoration: TextDecoration.none
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                          child: Material(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: TextField(
                              readOnly: true,
                              selectionControls: CustomColorSelectionHandle(Colors.transparent),
                              keyboardType: TextInputType.text,
                              controller: _toDateController,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                  ),
                                  border: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  hintText: "وقت النهاية"
                              ) ,
                              style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: primary,
                              ),
                              onTap: (){
                                _selectTime(context,2);
                              },
                            ),
                          ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(50)
                          ),

                          child: Text("إرسال الطلب",style: SafeGoogleFont (
                            'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),),
                          onPressed: () {
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
                                          Text('Sending Request...')
                                        ],
                                      ),
                                    ),
                                  );
                                });

                            addRequest().then((value) {
                              Navigator.pop(dialogContext);
                              Fluttertoast.showToast(
                                  msg: "تم إرسال الطلب بنجاح",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 20.0
                              );

                              setState(() {
                                SharedData.type = -1;
                              });
                            });
                          },
                        )

                      ],
                    ),
                  )
                ),
              ),

              Visibility(
                visible: SharedData.type == 2,
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
                                child: Text("طلب أجازة",style: SafeGoogleFont (
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

                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("تاريخ الطلب",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: TextField(
                                readOnly: true,
                                selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                keyboardType: TextInputType.text,
                                controller: _currentDateController,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "تاريخ الطلب"
                                ) ,
                                style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("تاريخ الأجازة",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: TextField(
                                readOnly: true,
                                selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                keyboardType: TextInputType.text,
                                controller: _dateController,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "تاريخ الأجازة"
                                ) ,
                                style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                ),
                                onTap: (){
                                  _selectDate(context);
                                },
                              ),
                            ),
                          ),



                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),

                            child: Text("إرسال الطلب",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),),
                            onPressed: () {
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
                                            Text('Sending Request...')
                                          ],
                                        ),
                                      ),
                                    );
                                  });

                              addRequest().then((value) {
                                Navigator.pop(dialogContext);
                                Fluttertoast.showToast(
                                    msg: "تم إرسال الطلب بنجاح",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 20.0
                                );

                                setState(() {
                                  SharedData.type = -1;
                                });
                              });
                            },
                          )

                        ],
                      ),
                    )
                ),
              ),

              Visibility(
                visible: SharedData.type == 3,
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
                                child: Text("طلب نسيان بصمة",style: SafeGoogleFont (
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

                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("تاريخ الطلب",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: TextField(
                                readOnly: true,
                                selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                keyboardType: TextInputType.text,
                                controller: _currentDateController,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "تاريخ الطلب"
                                ) ,
                                style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),




                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("تاريخ البصمة",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: TextField(
                                readOnly: true,
                                selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                keyboardType: TextInputType.text,
                                controller: _dateController,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey,width: 1.0)
                                    ),
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "تاريخ البصمة"
                                ) ,
                                style: SafeGoogleFont (
                                  'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: primary,
                                ),
                                onTap: (){
                                  _selectDate(context);
                                },
                              ),
                            ),
                          ),


                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("اختر وقت الطلب",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: DropDownTextField(
                                controller: _cnt2,
                                clearOption: true,
                                dropDownItemCount: types.length,
                                dropDownList: DropDownItems2(),
                                onChanged: (inde){
                                  DropDownItems();
                                },
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Text("اختر الدوام",style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                                color: primary,
                                decoration: TextDecoration.none
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: DropDownTextField(
                                controller: _cnt,
                                clearOption: true,
                                dropDownItemCount: workingHours.length,
                                dropDownList: items,
                              ),
                            ),
                          ),



                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),

                            child: Text("إرسال الطلب",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),),
                            onPressed: () {

                              WorkingHour workingHour = getWorkingHour();
                              print(workingHour.attend_time);
                              Attendance attendance = checkIfAttendanceExist(workingHour);
                              print(attendance.attend_at);
                              int whichType = _cnt2.dropDownValue?.value;
                              print(whichType);
                              bool canSend = true;

                              if(whichType == 0){

                                if(attendance.attend_at != ""){
                                  canSend = false;
                                  Fluttertoast.showToast(
                                      msg: "يوجد تسجيل حضور لهذا الدوام بالفعل",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 20.0
                                  );

                                }
                              }
                              else if(whichType == 1){
                                if(attendance.attend_at == ""){
                                  Fluttertoast.showToast(
                                      msg: "لا يوجد تسجيل حضور لهذا الدوام",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 20.0
                                  );
                                  canSend = false;
                                }
                                else if(attendance.leave_at != ""){
                                  Fluttertoast.showToast(
                                      msg: "يوجد تسجيل انصراف لهذا الدوام بالفعل",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 20.0
                                  );
                                  canSend = false;
                                }
                              }

                              print(canSend);
                              if(canSend){
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
                                              Text('Sending Request...')
                                            ],
                                          ),
                                        ),
                                      );
                                    });

                                addRequest().then((value) {
                                  Navigator.pop(dialogContext);
                                  Fluttertoast.showToast(
                                      msg: "تم إرسال الطلب بنجاح",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 20.0
                                  );

                                  setState(() {
                                    SharedData.type = -1;
                                  });
                                });
                              }

                            },
                          )

                        ],
                      ),
                    )
                ),
              ),

              Visibility(
                  visible: SharedData.type == -1,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Ink(
                                    decoration: const ShapeDecoration(
                                      color: primary,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(

                                        onPressed: (){
                                          setState(() {
                                            SharedData.type = 1;
                                          });
                                        },
                                        icon: Icon(Icons.upload_file),
                                      color: Colors.white,

                                    ),
                                  ),


                                  Text("طلب استئذان",style: SafeGoogleFont (
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Ink(
                                    decoration: const ShapeDecoration(
                                      color: primary,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(

                                      onPressed: (){
                                        setState(() {
                                          SharedData.type = 2;
                                        });
                                      },
                                      icon: Icon(Icons.airplane_ticket),
                                      color: Colors.white,

                                    ),
                                  ),


                                  Text("طلب أجازة",style: SafeGoogleFont (
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(40),
                                  ),
                                  Ink(
                                    decoration: const ShapeDecoration(
                                      color: primary,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(

                                      onPressed: (){
                                        setState(() {
                                          SharedData.type = 3;
                                        });
                                      },
                                      icon: Icon(Icons.fingerprint),
                                      color: Colors.white,

                                    ),
                                  ),


                                  Text("طلب نسيان بصمة",style: SafeGoogleFont (
                                    'Roboto',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  )),
                                ],
                              ),
                            ),

                          ],
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
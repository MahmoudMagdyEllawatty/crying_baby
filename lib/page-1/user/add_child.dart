import 'dart:convert';
import 'dart:math';

import 'package:CryingBaby/model/Advices.dart';
import 'package:CryingBaby/model/Child.dart';
import 'package:CryingBaby/model/ChildVaccines.dart';
import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/model/SharedData.dart';
import 'package:CryingBaby/model/Vaccine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show File, Platform;
import '../../colors.dart';
import '../../model/Messages.dart';
import '../../utils.dart';
import '../../widget/CustomColorSelectionHandle.dart';


class AddChild extends StatefulWidget {
  @override
  _AddChild createState() => _AddChild();
}

class _AddChild extends State<AddChild> {

  var _nameController = TextEditingController();
  var _birthdateController = TextEditingController();
  var _sexTypeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String imageUrl = "";
  String nextVaccineDate = "";

  List<Vaccine> vaccines = [];
  List<ChildVaccines> childVaccines = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _birthdateController.text = selectedDate.toLocal().toString().split(' ')[0];
        DateTime dv = DateTime.parse(_birthdateController.text);
        DateTime db= dv.add(Duration(days: 60));
        nextVaccineDate = DateFormat("yyyy-MM-dd").format(db);
      });
    }
  }

  Future<String> createChild() async{
    final docVaccine = FirebaseFirestore.instance
        .collection("childs")
        .doc();

    final notification = Child(
        name: _nameController.text,
        birth_date: _birthdateController.text,
        sexType : _sexTypeController.text,
        userKey: SharedData.currentUser.id,
        id: docVaccine.id);

    final json = notification.toJson();

    await docVaccine.set(json);

    await saveChildVaccines(notification.id);
    return "";
  }

  Future saveChildVaccines (String childKey) async{
    String birthDate = _birthdateController.text;
    for(Vaccine vaccine in vaccines){
      Duration duration = getDays(vaccine);
      if(duration.inDays > -1){
        DateTime dd = DateTime.parse(birthDate).add(duration);


        if(dd.isAfter(DateTime.now())){


        final docVaccine = FirebaseFirestore.instance
            .collection("child_vaccines")
            .doc();

        ChildVaccines childVaccine =ChildVaccines(
            id: docVaccine.id,
            childKey: childKey,
            vaccine: vaccine.name,
            image: "",
            date: DateFormat('yyyy-MM-dd').format(dd),
            state: 0);

        childVaccines.add(childVaccine);

        final notification = childVaccine;

        final json = notification.toJson();

        await docVaccine.set(json);


          scheduledNotification(year: dd.year, month: dd.month, day: dd.day, hour: 10, minutes: 0, seconds: 0,
              id: getRandomInteger(), sound: 'alarm', title: vaccine.name, desc: _nameController.text+" لديه تطعيم "+vaccine.name+" اليوم ");

        }



        
      }
    }
  }

  int getRandomInteger() {
    final random = Random();
    return random.nextInt(9999);
  }

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  scheduledNotification({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minutes,
    required int seconds,
    required int id,
    required String sound,
    required String title,
    required String desc
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      desc,
      _convertTime(year,month,day, hour, minutes,seconds),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Attendance Notifications',
          channelDescription: 'This channel is used for important attendance notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(sound),
          enableVibration: true,
          enableLights: true,

        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'It could be anything you pass',
    );
  }

  tz.TZDateTime _convertTime(int year,int month,int day, int hour, int minutes,int seconds) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduleDate = tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minutes,
        seconds
    );


    // if (scheduleDate.isBefore(now)) {
    //   scheduleDate = scheduleDate.add(const Duration(days: 1));
    // }
    // print('sc');

    return scheduleDate;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }


  Duration getDays(Vaccine vaccine){
    if(vaccine.day == "حديث الولادة"){
      return Duration(days: 0);
    }else if(vaccine.day == "شهر"){
      return Duration(days: 30);
    }else if(vaccine.day == "2 شهر"){
      return Duration(days: 60);
    }else if(vaccine.day == "3 أشهر"){
      return Duration(days: 90);
    }else if(vaccine.day == "4 أشهر"){
      return Duration(days: 120);
    }else if(vaccine.day == "6 أشهر"){
      return Duration(days: 180);
    }else if(vaccine.day == "8 أشهر"){
      return Duration(days: 240);
    }else if(vaccine.day == "10 أشهر"){
      return Duration(days: 300);
    }else if(vaccine.day == "11 أشهر"){
      return Duration(days: 330);
    }else if(vaccine.day == "عام"){
      return Duration(days: 365);
    }else if(vaccine.day == "18 أشهر"){
      return Duration(days: 540);
    }else if(vaccine.day == "عامان"){
      return Duration(days: 730);
    }

    return Duration(days: -1);
  }

  void loadVaccines() async{
    Stream<List<Vaccine>> vaccinesStram = await getVaccines();
    vaccinesStram.listen((event) {
      vaccines = event;
      setState(() {

      });
    });

  }

  Stream<List<Vaccine>> getVaccines() => FirebaseFirestore.instance
      .collection("vaccines")
      .snapshots()
      .map((event) => event.docs.map((e) => Vaccine.fromJson(e.data())).toList());


  @override
  void initState() {

    super.initState();
    setupInteractedMessage();
    loadVaccines();
  }

  Future<void> setupInteractedMessage() async {

    _configureLocalTimeZone();


    const androidSetting = AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
        android: androidSetting
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          //print(notificationResponse);

        }
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


  }

  @override
  void dispose() {

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.child_data),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
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
                                child: Text("إضافة طفل",style: SafeGoogleFont (
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
                            child: Text("اسم الطفل",style: SafeGoogleFont (
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
                                selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                keyboardType: TextInputType.text,
                                controller: _nameController,
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
                                    hintText: "اسم الطفل"
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
                            child: Text("تاريخ ميلاد الطفل",style: SafeGoogleFont (
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
                                controller: _birthdateController,
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
                                    hintText: "تاريخ ميلاد الطفل"
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
                          Text("موعد التطعيم القادم : "+nextVaccineDate,style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              decoration: TextDecoration.none
                          )),



                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),

                            child: Text("حفظ",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),),
                            onPressed: () {

                              BuildContext dialogContext = context;
                              showDialog(

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
                                            Text('جاري حفظ الطفل ...')
                                          ],
                                        ),
                                      ),
                                    );
                                  });

                              createChild().then((value) {
                                Navigator.pop(dialogContext);
                                Fluttertoast.showToast(
                                  msg: "تم الحفظ بنجاح",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 20.0
                                );
                                setState(() {
                                  SharedData.child_saved = true;
                                });


                                  Navigator.pop(context);

                            });


                            },
                          )

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
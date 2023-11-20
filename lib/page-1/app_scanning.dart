import 'dart:convert';

import 'package:CryingBaby/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Company.dart';
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
  String state = "";
  List<Device> devices = [];
  List<WorkingHour> workingHours = [];
  List<Attendance> attendance = [];


  DateTime now = DateTime.now();
  String formattedDate = "";
  bool isOnline = false;
  String secondPeriodDate= "";


  List<Company> parseSite(String responseBody){
    final parsed = json.decode(responseBody);
    return parsed.map<Company>((json){
      return Company.fromJson(json);
    }).toList();

  }


  Future<String> getSite() async {

    final response = await http.get(
      Uri.parse(SharedData.API_URL+"/site_settings"),
      headers: {"Content-type" : "application/json",
        "Accept":"application/json"},

    );
    if(response.statusCode == 200){
      setState(() {
        Company company = parseSite(response.body)[0];
        SharedData.currentCompany = company;
      });
      return "";
    }else{
      throw Exception('Cannot Save User');
    }
  }

  @override
  void initState() {
    super.initState();

    if(SharedData.currentCompany.name == ""){
      SharedData.currentCompany.enable_early_exit = "0";
      getSite();
    }

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
        SharedData.workingHours = workingHours;
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
        SharedData.attendance = attendance;
      });
      return "تم تسجيل الدخول بنجاح";
    }else{
      throw Exception('Cannot Save User');
    }
  }

  //endregion

  //region attendance

  Future<String> checkIn(String device,String actualTime) async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/check_in"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "device" : device,
          "actual_time" : actualTime
        })
    );
    if(response.statusCode == 200){

      setState(() {
        attendance = parseAttendance(response.body);
        SharedData.attendance = attendance;
      });
      return "Done";


    }else{
      throw Exception('Cannot Save User');
    }
  }

  Future<String> checkOut(String device,String actualTime) async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/check_out"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "employer_id": SharedData.user.id,
          "device" : device,
          "actual_time" : actualTime
        })
    );
    if(response.statusCode == 200){

      setState(() {
        attendance = parseAttendance(response.body);
        SharedData.attendance = attendance;
      });
      return "Done";


    }else{
      throw Exception('Cannot Save User');
    }
  }

  String checkDeviceExist(){
    for(int i =0;i< devices.length;i++){
      if(isDeviceExist(devices[i].device_mac)){
        setState(() {
          isOnline = true;
        });
        return devices[i].device_mac;
      }
    }
    setState(() {
      isOnline = false;
    });
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
      setState(() {
        state ='RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
            'locationServiceEnabled=${controller.locationServiceEnabled}, '
            'bluetoothEnabled=${controller.bluetoothEnabled}';
      });

      return;
    }
    setState(() {
      state = 'All Done';
    });
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

          setState(() {
            state += "\nSearching Devices";
          });

          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;



              _regionBeacons.values.forEach((list) {
                list.forEach((element) {
                  if(!checkIfExist(element.macAddress!)){
                    _beacons.addAll(list);
                  }
                });
              });
              checkDeviceExist();
              _beacons.sort(_compareParameters);
              state +="\n Devices Count:"+_beacons.length.toString();
            });
          }
        });
  }

  bool checkIfExist(String macAddress){
    for(int i=0;i<_beacons.length;i++){
      if(_beacons[i].macAddress! == macAddress){
        return true;
      }
    }
    return false;
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      // setState(() {
      //   _beacons.clear();
      // });
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

  void checkForNewSharedLists(){
    // do request here
    setState((){
      now = DateTime.now();
      formattedDate = DateFormat.jm().format(now);
      secondPeriodDate = DateFormat.Hms().format(now);

    });

  }


  Attendance checkIfAttendanceExist(WorkingHour workingHour){

    for(int i =0;i< attendance.length;i++){
      if(attendance[i].actual_attend_at == workingHour.attend_time){
        return attendance[i];
      }
    }

    return new Attendance("", "", "", "", "", "", "", "");
  }

  String getWeekDay(String day){
    if(day == "Saturday"){
      return AppLocalizations.of(context)!.saturday;
    }else if(day == "Sunday"){
    return AppLocalizations.of(context)!.sunday;
    }else if(day == "Monday"){
    return AppLocalizations.of(context)!.monday;
    }else if(day == "Tuesday"){
    return AppLocalizations.of(context)!.tuesday;
    }else if(day == "Wednesday"){
    return AppLocalizations.of(context)!.wednesday;
    }else if(day == "Thursday"){
    return AppLocalizations.of(context)!.thursday;
    }else{
    return AppLocalizations.of(context)!.friday;
    }
  }

  @override
  Widget build(BuildContext context) {

    int remainSeconds = 60 - DateTime.now().second;

    Timer(Duration(seconds: remainSeconds), () {
      Timer.periodic(Duration(seconds: 60), (Timer t) => checkForNewSharedLists());
    });



    formattedDate = DateFormat.jm().format(now);
    secondPeriodDate = DateFormat.Hms().format(now);
    String currentDay = getWeekDay(DateFormat('EEEE').format(now));
    final f = new DateFormat('yyyy-MM-dd');
    String currentDate = f.format(now);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
          width: double.infinity,
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [

                  Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text( formattedDate.contains("AM") ? "صباح الخير" : "مساء الخير",style: SafeGoogleFont (
                            'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          )),
                          Image.asset(
                            'assets/smile_face.png',
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          )
                        ],
                      ),
                      Text(SharedData.user.name,style: SafeGoogleFont (
                      'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    )),
                    ]
                  ),),
                  Container(
                    width: 70,
                    height: 70,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          side: BorderSide(
                            // border color
                              color: Colors.white,
                              // border thickness
                              width: 1)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Image.network(
                          (SharedData.user.image == "" ? SharedData.DEFAULT_IMAGE_URL : SharedData.IMAGE_URL+"/storage/app/"+SharedData.user.image),
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: workingHours.length,
                  itemBuilder: (context,index){

                    Attendance attend = checkIfAttendanceExist(workingHours[index]);
                    bool isTimeNow = (DateTime.parse('2000-01-01 ${secondPeriodDate}').isAfter(
                        DateTime.parse('2000-01-01 ${workingHours[index].attend_time}').add(Duration(minutes: -30)) ))
                    && (DateTime.parse('2000-01-01 ${secondPeriodDate}').isBefore(
                            DateTime.parse('2000-01-01 ${workingHours[index].leave_time}').add(Duration(minutes: 30)) ));

                    bool isTimeExit = (DateTime.parse('2000-01-01 ${secondPeriodDate}').isBefore(
                        DateTime.parse('2000-01-01 ${workingHours[index].leave_time}').add(Duration(minutes: 30)) ))
                    && (DateTime.parse('2000-01-01 ${secondPeriodDate}').isAfter(
                            DateTime.parse('2000-01-01 ${workingHours[index].leave_time}') ));

                    if(SharedData.currentCompany.enable_early_exit == 1){
                        bool isShiftStarted = (DateTime.parse('2000-01-01 ${secondPeriodDate}').isAfter(
                            DateTime.parse('2000-01-01 ${workingHours[index].attend_time}') ));
                        if(isShiftStarted)
                          isTimeExit = true;
                        else
                          isTimeExit = false;
                    }
                    if(isTimeNow) {
                      if (attend.day == "") {
                        return Card(
                          elevation: 10,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(15.0)),
                              side: BorderSide(
                                // border color
                                  color: primary,
                                  // border thickness
                                  width: 1)),
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(AppLocalizations.of(context)!
                                                  .attend,
                                                  style: SafeGoogleFont(
                                                    'Roboto',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.1725,
                                                    color: Color.fromARGB(
                                                        255, 253, 163, 13),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(visible: !isOnline,
                                        child: Icon(Icons.album_rounded,
                                          color: Colors.red, size: 20,)),
                                    Visibility(visible: isOnline,
                                        child: Icon(Icons.album_rounded,
                                          color: Colors.green, size: 20,))
                                  ],
                                ),
                                Divider(color: Colors.grey,),
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Center(child: Text(formattedDate,
                                      textAlign: TextAlign.center,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30.0),))),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: workingHours.length,
                                      itemBuilder: (context, indexS) {
                                        return Container(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          alignment: Alignment.center,
                                          child: Text("دوام اليوم : " +
                                              workingHours[indexS].attend_time +
                                              " - " +
                                              workingHours[indexS].leave_time
                                              , style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 20,
                                                fontWeight: indexS == index
                                                    ? FontWeight.bold
                                                    : FontWeight.w300,
                                                color: primary,
                                              )),
                                        );
                                      }),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size.fromHeight(50)
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.do_attend,
                                    style: SafeGoogleFont(
                                      'Roboto',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),),
                                  onPressed: () {
                                    String macAddress = checkDeviceExist();
                                    if (macAddress != "") {
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
                                                padding: const EdgeInsets
                                                    .symmetric(vertical: 20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  children: [
// The loading indicator
                                                    CircularProgressIndicator(),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
// Some text
                                                    Text(AppLocalizations.of(
                                                        context)!.attending)
                                                  ],
                                                ),
                                              ),
                                            );
                                          });

                                      checkIn(macAddress,
                                          workingHours[index].attend_time)
                                          .then((value) {
                                        Navigator.pop(dialogContext);
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context)!
                                              .devices_not_found,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 20.0
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      }
                      else if (attend.leave_at == '') {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(15.0)),
                              side: BorderSide(
                                // border color
                                  color: primary,
                                  // border thickness
                                  width: 1)),
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(AppLocalizations.of(context)!
                                                  .dismiss,
                                                  style: SafeGoogleFont(
                                                    'Roboto',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.1725,
                                                    color: Color.fromARGB(
                                                        255, 253, 163, 13),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(visible: !isOnline,
                                        child: Icon(Icons.album_rounded,
                                          color: Colors.red, size: 20,)),
                                    Visibility(visible: isOnline,
                                        child: Icon(Icons.album_rounded,
                                          color: Colors.green, size: 20,))
                                  ],
                                ),
                                Divider(color: Colors.grey,),
                                Container(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Stack(
                                      children: [
                                        Center(
                                            child: Image.asset(
                                              'assets/page-1/images/dismiss_clock.png',
                                              width: 230, height: 230,)

                                        ),
                                        Center(child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 50, 0, 0),
                                            child: Image.asset(
                                              "assets/hourglass.gif",
                                              width: 70,
                                              height: 70,

                                            )
                                        ),),
                                        Center(child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 130, 0, 0),
                                            child: Text(
                                              (DateTime.parse(
                                                  '2000-01-01 ${workingHours[index]
                                                      .leave_time}')
                                                  .difference(DateTime.parse(
                                                  '2000-01-01 ${secondPeriodDate}')))
                                                  .toString()
                                                  .substring(0, (DateTime.parse(
                                                  '2000-01-01 ${workingHours[index]
                                                      .leave_time}')
                                                  .difference(DateTime.parse(
                                                  '2000-01-01 ${secondPeriodDate}')))
                                                  .toString()
                                                  .lastIndexOf(":"))
                                              , textAlign: TextAlign.center,
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30.0,
                                                  color: Colors.white),))),

                                      ],
                                    )
                                ),

                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: workingHours.length,
                                      itemBuilder: (context, indexS) {
                                        return Container(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          alignment: Alignment.center,
                                          child: Text("دوام اليوم : " +
                                              workingHours[indexS].attend_time +
                                              " - " +
                                              workingHours[indexS].leave_time
                                              , style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 20,
                                                fontWeight: indexS == index
                                                    ? FontWeight.bold
                                                    : FontWeight.w300,
                                                color: primary,
                                              )),
                                        );
                                      }),
                                ),

                                Visibility(
                                  visible: isTimeExit,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size.fromHeight(50)
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.do_dismiss,
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),),
                                    onPressed: () {
                                      String macAddress = checkDeviceExist();
                                      if (macAddress != "") {
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 20),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
// The loading indicator
                                                      CircularProgressIndicator(),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
// Some text
                                                      Text(AppLocalizations.of(
                                                          context)!.dismissing)
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });

                                        checkOut(macAddress,
                                            workingHours[index].leave_time)
                                            .then((value) {
                                          Navigator.pop(dialogContext);
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!
                                                .devices_not_found,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 20.0
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    }


                    return Text("");
                  }
              ),
              Visibility(
                visible: workingHours.isNotEmpty,
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
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("احصائيات ("+currentDay+")"+" الموافق "+currentDate,style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.1725,
                              color: Color.fromARGB(255, 253, 163, 13),
                            )),
                          ],
                        ),
                        Divider(color: Colors.grey,),
                        ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: workingHours.length,
                            itemBuilder: (context,index){

                              Attendance attend = checkIfAttendanceExist(workingHours[index]);
                              return Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("موعد الدوام من "+workingHours[index].attend_time+" الى " + workingHours[index].leave_time,style: SafeGoogleFont (
                                        'Roboto',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300,
                                        color: primary,
                                      )),
                                      Visibility(
                                        visible: attend.day != "",
                                        child: Text("تسجيل الحضور  : "+
                                            (attendance.length >= (index+1) ? attendance[index].attend_at: "")
                                            +"\nتسجيل الانصراف : "+
                                            (attendance.length >= (index+1) ? attendance[index].leave_at: "")
                                            ,style: SafeGoogleFont (
                                              'Roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            )),
                                      ),
                                      Visibility(
                                        visible: (attend.day == ""
                                            && (DateTime.parse('2000-01-01 ${secondPeriodDate}').isAfter(
                                                DateTime.parse('2000-01-01 ${workingHours[index].attend_time}').add(Duration(minutes: -30)) )))
                                            ,
                                        child: Text("لم يتم تسجيل الحضور"
                                            ,style: SafeGoogleFont (
                                              'Roboto',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.red,
                                            )),
                                      ),
                                      Visibility(
                                        visible: attend.day == "" &&
                                            (DateTime.parse('2000-01-01 ${secondPeriodDate}').isBefore(DateTime.parse('2000-01-01 ${workingHours[index].attend_time}').add(Duration(minutes: -30)) )),
                                        child: Text("لم يبدأ الدوام بعد"
                                            ,style: SafeGoogleFont (
                                              'Roboto',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey,
                                            )),
                                      ),
                                    ],
                                  ),
                                );



                            }),

                      ],
                    ),
                  ),
                ),
              ),




            ],
          ),
        ),
      ),
    );
  }


}
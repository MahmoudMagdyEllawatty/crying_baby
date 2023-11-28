import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:CryingBaby/colors.dart';
import 'package:CryingBaby/model/User.dart';
import 'package:CryingBaby/page-1/admin/admin_home.dart';
import 'package:CryingBaby/page-1/register.dart';
import 'package:CryingBaby/page-1/user/user_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Company.dart';
import '../model/EmployerLogin.dart';
import '../model/SharedData.dart';
import '../utils.dart';
import '../widget/CustomColorSelectionHandle.dart';



class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginWidget();
  }

}

class _LoginWidget extends State<Login>{

  var _phoneContrller = TextEditingController();
  var _passwordContrller = TextEditingController();

  List<User> allUsers = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<EmployerLogin> parseUser(String responseBody){
    final parsed = json.decode(responseBody);
    return parsed.map<EmployerLogin>((json){
      return EmployerLogin.fromMap(json);
    }).toList();

  }

  Future<String> checkLogin() async {

    String email = _phoneContrller.text.toString();
    String password = _passwordContrller.text.toString();

    if(email == "admin@baby.com" && password == "123456"){
      final SharedPreferences prefs = await _prefs;
      prefs.setString("phone", email);
      prefs.setString("password", password);
      SharedData.userType = 0;
      return "Admin";
    }else{


      for(User user in allUsers){
        if(user.email == email && user.password == password){
          SharedData.currentUser = user;
          final SharedPreferences prefs = await _prefs;
          prefs.setString("phone", email);
          prefs.setString("password", password);
          SharedData.userType = 1;
          return "User";
        }
      }
    }

    return "Not Found";
  }

  Stream<List<User>> getUsers() => FirebaseFirestore.instance
      .collection("users")
      .snapshots()
      .map((event) => event.docs.map((e) => User.fromJson(e.data())).toList());



  Future loadUsers() async{

    Stream<List<User>> usersStream = await getUsers();
    usersStream.listen((event) {
      for(User user in event){
        allUsers.add(user);
      }
      loadSavedData();
    });
  }

  void loadSavedData(){
    _prefs.then((value) {
      String phone = value.getString("phone") ?? "";
      String password = value.getString("password") ?? "";

      if(phone.isNotEmpty){

        setState(() {
          _phoneContrller.text = phone;
          _passwordContrller.text = password;
        });


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
                      Text('Loading...')
                    ],
                  ),
                ),
              );
            });

        checkLogin().then((value){
          Navigator.pop(dialogContext);

          if(value == 'Not Found'){
            Fluttertoast.showToast(
                msg: "Phone or Password is not correct",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          else{

            if(value == 'Admin'){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminHome()),
                    (Route<dynamic> route) => false,
              );
            }else if(value == 'User'){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => UserHome()),
                    (Route<dynamic> route) => false,
              );
            }

          }

        });
      }
      else{

      }

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();

    loadUsers()
    .then((mm) => {

    });




  }


  void requestPermission() async{
    Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted && statuses[Permission.bluetoothScan] == PermissionStatus.granted) {
      // permission granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 246, 246),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 60, 20, 24),
          width: double.infinity,
          decoration: BoxDecoration(

            image: DecorationImage(
              image: AssetImage("assets/new_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      side: BorderSide(
                        // border color
                          color: Colors.white,
                          // border thickness
                          width: 1)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
              ),
              Center(
                  child: Text("Crying Baby",style: SafeGoogleFont (
                    'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.none
                  ))
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
                  child: Text(AppLocalizations.of(context)!.login,style: SafeGoogleFont (
                    'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1.1725,
                    color: Colors.black,
                      decoration: TextDecoration.none
                  )),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(AppLocalizations.of(context)!.email_or_employer_code,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                    decoration: TextDecoration.none
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Material(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: TextField(
                    selectionControls: CustomColorSelectionHandle(Colors.transparent),
                    keyboardType: TextInputType.emailAddress,
                    controller: _phoneContrller,
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
                        hintText: AppLocalizations.of(context)!.email_or_employer_code
                    ) ,
                    style: SafeGoogleFont (
                      'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.password,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                    decoration: TextDecoration.none
                )),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Material(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: TextField(
                    selectionControls: CustomColorSelectionHandle(Colors.transparent),
                    keyboardType: TextInputType.text,
                    controller: _passwordContrller,
                    obscureText: true,
                    autocorrect: false,
                    obscuringCharacter: "*",
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
                        hintText: AppLocalizations.of(context)!.password
                    ) ,
                    style: SafeGoogleFont (
                      'Roboto',
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50)
                  ),
                  child: Text(AppLocalizations.of(context)!.login,style: SafeGoogleFont (
                    'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),),
                  onPressed: () {
                    if(_phoneContrller.text.isNotEmpty && _passwordContrller.text.isNotEmpty){
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
                                    Text('Loading...')
                                  ],
                                ),
                              ),
                            );
                          });

                      checkLogin().then((value){
                        Navigator.pop(dialogContext);

                        if(value == 'Not Found'){
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.invalid_email_or_password,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                        else{

                          if(value == 'Admin'){
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => AdminHome()),
                                  (Route<dynamic> route) => false,
                            );
                          }else if(value == 'User'){
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => UserHome()),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        }

                      });
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "Please,Complete Fields first",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                )
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child:  TextButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)
                    ),
                    child: Text(AppLocalizations.of(context)!.register,style: SafeGoogleFont (
                      'Roboto',
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                      color: primary,
                    ),),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder:(context) => Register()));
                    },
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }
}
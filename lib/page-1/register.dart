import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:CryingBaby/colors.dart';
import 'package:CryingBaby/model/User.dart';
import 'package:CryingBaby/page-1/admin/admin_home.dart';
import 'package:CryingBaby/page-1/login.dart';
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


class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterWidget();
  }

}

class _RegisterWidget extends State<Register>{

  var _nameContrller = TextEditingController();
  var _phoneContrller = TextEditingController();
  var _passwordContrller = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();

  }

  Future createNewAccount() async{
    final docVaccine = FirebaseFirestore.instance
        .collection("users")
        .doc();

    final notification = User(
        name: _nameContrller.text,
        email: _phoneContrller.text,
        password: _passwordContrller.text,
        id: docVaccine.id);

    final json = notification.toJson();

    await docVaccine.set(json);
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
                  child: Text(AppLocalizations.of(context)!.register,style: SafeGoogleFont (
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
                child: Text(AppLocalizations.of(context)!.name,style: SafeGoogleFont (
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
                    controller: _nameContrller,
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
                        hintText: AppLocalizations.of(context)!.name
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
                  child: Text(AppLocalizations.of(context)!.register,style: SafeGoogleFont (
                    'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),),
                  onPressed: () {
                    if(_phoneContrller.text.isNotEmpty && _passwordContrller.text.isNotEmpty && _nameContrller.text.isNotEmpty){
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

                      createNewAccount().then((value){
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

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                                (Route<dynamic> route) => false,
                          );
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


            ],
          ),
        ),
      ),
    );
  }
}
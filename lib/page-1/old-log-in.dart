import 'dart:convert';
import 'dart:math';

import 'package:CryingBaby/page-1/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/EmployerLogin.dart';
import '../model/SharedData.dart';
import '../utils.dart';
import '../widget/CustomColorSelectionHandle.dart';
import 'home.dart';


class OldLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginWidget();
  }

}

class _LoginWidget extends State<OldLogin>{

  var _phoneContrller = TextEditingController();
  var _passwordContrller = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<EmployerLogin> parseUser(String responseBody){
    final parsed = json.decode(responseBody);
    return parsed.map<EmployerLogin>((json){
      return EmployerLogin.fromMap(json);
    }).toList();

  }

  Future<String> checkLogin() async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/check_login"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "phone": _phoneContrller.text.toString(),
          "password" : _passwordContrller.text.toString()
        })
    );
    if(response.statusCode == 200){
      EmployerLogin login = parseUser(response.body)[0];

      if(login.code == 200){
        SharedData.user = login.user!;

        final SharedPreferences prefs = await _prefs;
        prefs.setString("phone", _phoneContrller.text.toString());
        prefs.setString("password", _passwordContrller.text.toString());
        return "تم تسجيل الدخول بنجاح";
      }else{
        return login.msg;
      }



    }else{
      throw Exception('Cannot Save User');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  void requestPermission() async{
    Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted && statuses[Permission.bluetoothScan] == PermissionStatus.granted) {
      // permission granted
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      child: Container(
        // loginVCj (1:16)
        width: double.infinity,
        height: 815*fem,
        child: Container(
          // iphonexxs8Ay5 (1:17)
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration (
            image: DecorationImage (
              fit: BoxFit.cover,
              image: AssetImage (
                'assets/page-1/images/vector.png',
              ),
            ),
          ),
          child: Container(
            // rectangle25f99 (1:19)
            padding: EdgeInsets.fromLTRB(3*fem, 145*fem, 0*fem, 0*fem),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration (
              color: Color(0xffe8e8e8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // multipledifferentcheckmarkscop (1:92)
                  margin: EdgeInsets.fromLTRB(24*fem, 0*fem, 0*fem, 10*fem),
                  width: 160*fem,
                  height: 170*fem,
                  child: Image.asset(
                    'assets/page-1/images/multipledifferentcheckmarks-copy-1.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  // group209rcw (1:20)
                  margin: EdgeInsets.fromLTRB(30*fem, 0*fem, 30*fem, 32*fem),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // passnWb (1:26)
                        width: double.infinity,
                        height: 50*fem,
                        child: Stack(
                          children: [
                            Positioned(
                              // groupKmR (1:27)
                              left: 0*fem,
                              top: 0*fem,
                              child: Align(
                                child: SizedBox(
                                  width: 300*fem,
                                  height: 50*fem,
                                  child: Image.asset(
                                    'assets/page-1/images/group.png',
                                    width: 300*fem,
                                    height: 50*fem,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // emailogb (1:29)
                              child: Align(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(18*fem, 10*fem, 18*fem, 0*fem),
                                  child: SizedBox(
                                    height: 24*fem,
                                    child: Material(
                                      child: TextField(
                                        selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                        keyboardType: TextInputType.phone,
                                        textAlign: TextAlign.left,
                                        controller: _phoneContrller,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: 'Phone ...'
                                        ) ,
                                        style: SafeGoogleFont (
                                          'Roboto',
                                          fontSize: 19*ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.1725*ffem/fem,
                                          color: Color(0xff464a5f),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 28.42*fem,
                      ),
                      Container(
                        // passd9q (1:21)
                        width: double.infinity,
                        height: 50*fem,
                        child: Stack(
                          children: [
                            Positioned(
                              // group9ts (1:22)
                              left: 0*fem,
                              top: 0*fem,
                              child: Align(
                                child: SizedBox(
                                  width: 300*fem,
                                  height: 50*fem,
                                  child: Image.asset(
                                    'assets/page-1/images/group-caB.png',
                                    width: 300*fem,
                                    height: 50*fem,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // emailogb (1:29)
                              child: Align(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(18*fem, 10*fem, 18*fem, 0*fem),
                                  child: SizedBox(
                                    height: 24*fem,
                                    child: Material(
                                      child: TextField(
                                        selectionControls: CustomColorSelectionHandle(Colors.transparent),
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.left,
                                        controller: _passwordContrller,
                                        obscureText: true,
                                        autocorrect: false,
                                        obscuringCharacter: "*",
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: 'Password ...'
                                        ) ,
                                        style: SafeGoogleFont (
                                          'Roboto',
                                          fontSize: 19*ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.1725*ffem/fem,
                                          color: Color(0xff464a5f),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 28.42*fem,
                      ),
                      Container(
                        // groupKwm (1:31)
                        width: double.infinity,
                        height: 43.06*fem,
                        decoration: BoxDecoration (
                          image: DecorationImage (
                            fit: BoxFit.cover,
                            image: AssetImage (
                              'assets/page-1/images/login-button-shape-87H.png',
                            ),
                          ),

                        ),
                        child: TextButton(
                          // buttonsdSf (1:33)
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

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false,
                                  );
                                }

                              });
                            }else{
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
                                  // ellipse1Hn7 (I1:33;6:493)
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
                                  // loginBMh (1:34)
                                  left: 106*fem,
                                  top: 8.055557251*fem,
                                  child: Align(
                                    child: SizedBox(
                                      width: 62*fem,
                                      height: 30*fem,
                                      child: Text(
                                        'log in',
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
                    ],
                  ),
                ),
                Container(
                  // copy1T4K (1:93)
                  width: 372*fem,
                  height: 250*fem,
                  child: Image.asset(
                    'assets/page-1/images/copy-1.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:CryingBaby/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show File, Platform;
import '../controller/requirement_state_controller.dart';
import '../model/Attendance.dart';
import '../model/Device.dart';
import '../model/EmployerLogin.dart';
import '../model/SharedData.dart';
import '../model/WorkingHour.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import '../widget/AnimationClick.dart';
import '../widget/CustomColorSelectionHandle.dart';

class TabProfile extends StatefulWidget {
  @override
  _TabProfileState createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {

  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _passwordController = TextEditingController();

  late File _image;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<EmployerLogin> parseUser(String responseBody){
    final parsed = json.decode(responseBody);
    return parsed.map<EmployerLogin>((json){
      return EmployerLogin.fromMap(json);
    }).toList();

  }

  Future<String> checkLogin() async {

    final response = await http.post(
        Uri.parse(SharedData.API_URL+"/update_profile"),
        headers: {"Content-type" : "application/json",
          "Accept":"application/json"},
        body: jsonEncode({
          "phone": _phoneController.text.toString(),
          "name": _nameController.text.toString(),
          "password" : _passwordController.text.toString(),
          "employer_id": SharedData.user.id
        })
    );
    if(response.statusCode == 200){
      EmployerLogin login = parseUser(response.body)[0];

      if(login.code == 200){
        setState(() {
          SharedData.user = login.user!;
        });


        final SharedPreferences prefs = await _prefs;
        prefs.setString("phone", _phoneController.text.toString());
        if(_passwordController.text.isNotEmpty)
          prefs.setString("password", _passwordController.text.toString());

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
    super.initState();

    setState(() {
      _phoneController.text = SharedData.user.phone;
      _nameController.text = SharedData.user.name;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  void uploadImage() async {


    var request = http.MultipartRequest('POST',Uri.parse(SharedData.API_URL+"/update_profile_image"))
      ..fields['employer_id'] = SharedData.user.id;
    // ..fields['user'] = 'nweiz@google.com';
    request.files.add(await http.MultipartFile.fromPath("file", _image.path));

    final response = await request.send();
    final responseBodyStream = await response.stream.bytesToString();
    Map? responseBody = json.decode(responseBodyStream.toString());

    if(responseBody != null)
    {

      if(responseBody['state'] == 200)
      {

        setState(() {
          SharedData.user.image = responseBody['message'];
          print(SharedData.user.image);
        });

      }
    }
    else
    {

    }



  }

  getImageGallery() async {
    final ImagePicker picker = ImagePicker();
    XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(imageFile!.path);
      uploadImage();
    });
  }

  getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    XFile? imageFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(imageFile!.path);
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(""),
              ),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 49,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: Image.network(
                            (SharedData.user.image == "" ? SharedData.DEFAULT_IMAGE_URL : SharedData.IMAGE_URL+"/storage/app/"+SharedData.user.image),
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,

                          ),
                        ),
                        radius: 45,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: createIconCircle(context,
                            hasShadow: false,
                            onPressed: () {

                              getImageGallery();

                            },
                            iconData: Icons.edit,
                            sizeIcon: 16,
                            iconColor: primary,
                            bgColor: Colors.white,
                      ),
                    )
                        )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("الاسم",style: SafeGoogleFont (
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
                        hintText: "الاسم"
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
                child: Text("رقم الجوال",style: SafeGoogleFont (
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
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
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
                        hintText: "رقم الجوال"
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
                    controller: _passwordController,
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
                    child: Text("تعديل الملف الشخصي",style: SafeGoogleFont (
                      'Roboto',
                      fontSize: 21,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),),
                    onPressed: () {
                      if(_phoneController.text.isNotEmpty && _nameController.text.isNotEmpty){
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
                                      Text('تحديث الملف الشخصي...')
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

  Widget createIconCircle(BuildContext context,
      {IconData? iconData,
        String? pathIcon,
        Function()? onPressed,
        Color? bgColor,
        Color? iconColor,
        double sizeIcon = 24,
        bool hasShadow = true}) {
    return AnimationClick(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
            boxShadow: hasShadow
                ? const [
              BoxShadow(
                  color: Color.fromRGBO(58, 34, 40, 0.16),
                  offset: Offset(0, 10),
                  blurRadius: 16)
            ]
                : const [
              BoxShadow(
                  color: const Color.fromRGBO(223, 191, 171, 100),
                  blurRadius: 10,
                  offset: Offset(4, 8))
            ],
            color: bgColor ?? primary,
            borderRadius: BorderRadius.circular(40)),
        child: IconButton(
            icon: pathIcon != null
                ? Image.asset(
              pathIcon,
              height: sizeIcon,
              width: sizeIcon,
              color: primary,
            )
                : Icon(
              iconData,
              color: iconColor ?? primary,
              size: sizeIcon,
            ),
            onPressed: onPressed != null ? onPressed : () {}),
      ),
    );
  }
}
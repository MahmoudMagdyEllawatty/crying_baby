import 'dart:convert';

import 'package:CryingBaby/model/Advices.dart';
import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/model/Vaccine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show File, Platform;
import '../../colors.dart';
import '../../model/Messages.dart';
import '../../utils.dart';
import '../../widget/CustomColorSelectionHandle.dart';


class AddAdvice extends StatefulWidget {
  @override
  _AddAdvice createState() => _AddAdvice();
}

class _AddAdvice extends State<AddAdvice> {

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  String imageUrl = "";



  Future createVaccine() async{
    final docVaccine = FirebaseFirestore.instance
        .collection("advices")
        .doc();

    final notification = Advices(
        image: imageUrl,
        description: _descriptionController.text,
        title: _nameController.text,
        id: docVaccine.id);

    final json = notification.toJson();

    await docVaccine.set(json);

  }

  @override
  void initState() {

    super.initState();

  }

  @override
  void dispose() {

    super.dispose();
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    XFile? image;
    //Check Permissions
    await Permission.photos.request();






      //Select Image
      image = await _imagePicker.pickImage(source: ImageSource.gallery);


      if (image != null){
        var file = File(image.path);
        //Upload to Firebase
        var reference = _firebaseStorage.ref(file.path);
        final TaskSnapshot snapshot = await reference.putFile(file);

        var downloadUrl =   await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.advice_data),
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
                                child: Text("إضافة نصيحة",style: SafeGoogleFont (
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
                            child: Text("عنوان النصيحة",style: SafeGoogleFont (
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
                                    hintText: "عنوان النصيحة"
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
                            child: Text("محتوى النصيحة",style: SafeGoogleFont (
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
                                controller: _descriptionController,
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
                                    hintText: "محتوى النصيحة"
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
                              margin: EdgeInsets.all(15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                border: Border.all(color: Colors.white),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 2),
                                    spreadRadius: 2,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  uploadImage();
                                },
                                child: (imageUrl != "")
                                    ? Image.network(imageUrl)
                                    : Image.network('https://i.imgur.com/sUFH1Aq.png'),
                              )
                          ),





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

                                createVaccine();

                                Fluttertoast.showToast(
                                    msg: "تم الحفظ بنجاح",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 20.0
                                );

                                Navigator.pop(context);

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
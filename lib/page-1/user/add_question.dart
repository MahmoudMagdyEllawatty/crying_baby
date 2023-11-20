import 'dart:convert';

import 'package:CryingBaby/model/Advices.dart';
import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/model/Question.dart';
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


class AddQuestion extends StatefulWidget {
  @override
  _AddQuestion createState() => _AddQuestion();
}

class _AddQuestion extends State<AddQuestion> {

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  String imageUrl = "";



  Future createVaccine() async{
    final docVaccine = FirebaseFirestore.instance
        .collection("questions")
        .doc();

    final notification = Question(
        answer: "",
        date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        question: _nameController.text,
        userName: SharedData.currentUser.name,
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
        var snapshot = await _firebaseStorage.ref()
            .child('images/imageName');
            snapshot.putFile(file);
        var downloadUrl = await snapshot.getDownloadURL();
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
                                child: Text("إضافة سؤال",style: SafeGoogleFont (
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
                            child: Text("نص السؤال",style: SafeGoogleFont (
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
                                    hintText: "أكتب ما تريد ان تسأل عنه"
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
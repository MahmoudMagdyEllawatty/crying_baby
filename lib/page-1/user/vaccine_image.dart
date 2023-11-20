import 'dart:convert';

import 'package:CryingBaby/model/Advices.dart';
import 'package:CryingBaby/model/ChildVaccines.dart';
import 'package:CryingBaby/model/Diary.dart';
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
import '../../model/SharedData.dart';
import '../../utils.dart';
import '../../widget/CustomColorSelectionHandle.dart';


class VaccineImage extends StatefulWidget {
  @override
  _AddDiary createState() => _AddDiary();
}

class _AddDiary extends State<VaccineImage> {

  String imageUrl = "";


  @override
  void initState() {

    super.initState();
    setState(() {
      imageUrl = SharedData.currentVaccine.image;
    });

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

        ChildVaccines childVaccines = ChildVaccines(childKey: SharedData.currentVaccine.childKey,
            vaccine: SharedData.currentVaccine.vaccine,
            date: SharedData.currentVaccine.date,
            state: SharedData.currentVaccine.state,
            id: SharedData.currentVaccine.id,
            image: imageUrl);

        final docVaccine = FirebaseFirestore.instance
            .collection("child_vaccines")
            .doc(SharedData.currentVaccine.id);
        final json = childVaccines.toJson();

        await docVaccine.set(json);


      } else {
        print('No Image Path Received');
      }

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text("صورة التطعيم"),
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
                                child: Text("",style: SafeGoogleFont (
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
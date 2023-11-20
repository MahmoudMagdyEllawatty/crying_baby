import 'dart:convert';

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/model/Vaccine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../colors.dart';
import '../../model/SharedData.dart';
import '../../utils.dart';
import '../../widget/CustomColorSelectionHandle.dart';


class EditVaccine extends StatefulWidget {
  @override
  _AddVaccine createState() => _AddVaccine();
}

class _AddVaccine extends State<EditVaccine> {

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  late SingleValueDropDownController _cnt2;
  Vaccine vaccine = Vaccine(day: "", description: "", name: "");

  List<String> types = [
    "حديث الولادة",
    "أسبوع",
    "أسبوعان",
    "شهر",
    "2 شهر",
    "4 أشهر",
    "5 أشهر",
    "6 أشهر",
    "7 أشهر",
    "8 أشهر",
    "9 أشهر",
    "10 أشهر",
    "11 أشهر",
    "عام",
    "13 أشهر",
    "14 أشهر",
    "15 أشهر",
    "16 أشهر",
    "17 أشهر",
    "18 أشهر",
    "19 أشهر",
    "20 أشهر",
    "21 أشهر",
    "22 أشهر",
    "23 أشهر",
    "عامان"
  ];

  Future createVaccine() async{
    final docVaccine = FirebaseFirestore.instance
        .collection("vaccines")
        .doc(vaccine.id);

    final vaccine1 = Vaccine(day: _cnt2.dropDownValue!.name,
        description: _descriptionController.text,
        name: _nameController.text,
        id: vaccine.id);

    final json = vaccine1.toJson();

    await docVaccine.set(json);

  }

  @override
  void initState() {
    vaccine = SharedData.vaccine;
    _cnt2 = SingleValueDropDownController();

    setState(() {
      _nameController.text = vaccine.name;
      _descriptionController.text = vaccine.description;
      _cnt2.dropDownValue = DropDownValueModel(name: vaccine.day, value: vaccine.day);
    });


    super.initState();

  }

  @override
  void dispose() {
    _cnt2.dispose();
    super.dispose();
  }



  List<DropDownValueModel> DropDownItems2(){
    List<DropDownValueModel> items = [];
    for(var i = 0; i < types.length;i++){

      items.add(DropDownValueModel(name:types[i],
          value:types[i]));
    }

    return items;
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.add_vaccine),
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
                                child: Text("إضافة موعد تطعيم",style: SafeGoogleFont (
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
                            child: Text("اسم التطعيم",style: SafeGoogleFont (
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
                                    hintText: "اسم التطعيم"
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
                            child: Text("وصف التطعيم",style: SafeGoogleFont (
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
                                    hintText: "وصف التطعيم"
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
                            child: Text("اختر موعد التطعيم",style: SafeGoogleFont (
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
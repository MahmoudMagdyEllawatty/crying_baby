

import 'package:CryingBaby/model/Child.dart';
import 'package:CryingBaby/model/ChildDrug.dart';
import 'package:CryingBaby/model/ChildVaccines.dart';
import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/page-1/admin/add_vaccine.dart';
import 'package:CryingBaby/page-1/admin/edit_vaccine.dart';
import 'package:CryingBaby/page-1/user/vaccine_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import '../../colors.dart';
import '../../model/SharedData.dart';
import '../../model/Vaccine.dart';
import 'package:http/http.dart' as http;

import '../../utils.dart';
import 'add_child_drug.dart';


class ChildDrugsList extends StatefulWidget {
  @override
  _ChildDrugsList createState() => _ChildDrugsList();
}

class _ChildDrugsList extends State<ChildDrugsList> {

  List<ChildDrug> vaccines = [];

  @override
  void initState(){
    super.initState();
    loadVaccines();
  }

  void loadVaccines() async{
    Stream<List<ChildDrug>> vaccinesStram = getVaccines();
    List<ChildDrug> allVaccines = await vaccinesStram.first;
    setState((){
      allVaccines.forEach((element) {
          if(element.childKey == SharedData.currentChild.id){
            vaccines.add(element);
          }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<ChildDrug>> getVaccines() => FirebaseFirestore.instance
      .collection("child_drugs")
      .where("childKey",isEqualTo: SharedData.currentChild.id)
      .orderBy("date")
      .snapshots()
      .map((event) => event.docs.map((e) => ChildDrug.fromJson(e.data())).toList());


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text(" الأدوية " + SharedData.currentChild.name),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

                Card(
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
                                      Text('جميع الأدوية',
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
                          ],
                        ),
                        Divider(color: Colors.grey,),
                        StreamBuilder<List<ChildDrug>>(
                          stream: getVaccines(),
                          builder: (context,snap){
                            if(snap.hasError){
                              return Text("Something went wrong");
                            }else if(snap.hasData){
                              vaccines = snap.data!;
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: vaccines.length,
                                itemBuilder: (context,index){
                                  return buildVaccine(vaccines[index]);
                                },
                              );
                            }else{
                              return Center(child: CircularProgressIndicator(),);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),



            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder:(context) => AddChildDrug()));

        },
      ),
    );
  }

  int getMonthsCount(String date){
    return 50;
  }

  setVaccineTaken(ChildDrug vaccine) async{
    ChildDrug childVaccine =ChildDrug(
        id: vaccine.id,
        childKey: vaccine.childKey,
        drug: vaccine.drug,
        dosage: vaccine.dosage,
        times: vaccine.dosage,
        end_date: vaccine.end_date,
        date: vaccine.date,
        state: 1);

    final docVaccine = FirebaseFirestore.instance
        .collection("child_drugs")
        .doc(vaccine.id);

    final json = childVaccine.toJson();

    await docVaccine.set(json);
  }

  Widget buildVaccine(ChildDrug vaccine) => Container(
    child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          side: BorderSide(
            // border color
              color: primary,
              // border thickness
              width: 1)),
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(vaccine.drug+"\n"+vaccine.dosage+"\n"+vaccine.times+" مرات في اليوم" ,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.1725,
                  color: primary,
                )),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(vaccine.date,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1725,
                  color: Colors.black,
                )),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(visible: vaccine.state == 1,
                        child: Icon(Icons.album_rounded,
                          color: Colors.green, size: 20,)),
                    Visibility(visible: vaccine.state == 0 && getMonthsCount(vaccine.date) <= 60,
                        child: Icon(Icons.album_rounded,
                          color: Colors.orange, size: 20,)),
                    Visibility(visible: vaccine.state == 0 && getMonthsCount(vaccine.date) > 60,
                        child: Icon(Icons.album_rounded,
                          color: Colors.red, size: 20,)),

                    Visibility(visible: vaccine.state == 0,
                        child: Checkbox(
                          value: false,
                          onChanged: (value){
                            if(value == true){
                              setVaccineTaken(vaccine);
                            }
                          },
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );


}
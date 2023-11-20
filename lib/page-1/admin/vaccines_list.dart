

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/page-1/admin/add_vaccine.dart';
import 'package:CryingBaby/page-1/admin/edit_vaccine.dart';
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


class TabVaccines extends StatefulWidget {
  @override
  _TabVaccines createState() => _TabVaccines();
}

class _TabVaccines extends State<TabVaccines> {

  List<Vaccine> vaccines = [];

  @override
  void initState(){
    super.initState();
    //loadVaccines();
  }

  void loadVaccines() async{
    Stream<List<Vaccine>> vaccinesStram = getVaccines();
    List<Vaccine> allVaccines = await vaccinesStram.first;
    setState((){
      vaccines = allVaccines;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<Vaccine>> getVaccines() => FirebaseFirestore.instance
      .collection("vaccines")
      .snapshots()
      .map((event) => event.docs.map((e) => Vaccine.fromJson(e.data())).toList());


  @override
  Widget build(BuildContext context) {



    return Scaffold(

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

          StreamBuilder<List<Vaccine>>(
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
              builder:(context) => AddVaccine()));

        },
      ),
    );
  }

  Widget buildVaccine(Vaccine vaccine) => Container(
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
                child: Text(vaccine.name ,style: SafeGoogleFont (
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
                child: Text(vaccine.day ,style: SafeGoogleFont (
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
                    IconButton(onPressed: (){
                      SharedData.vaccine = vaccine;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder:(context) => EditVaccine()));
                    }, icon: Icon(Icons.edit_outlined,color: primary,)),
                    IconButton(onPressed: (){
                        FirebaseFirestore.instance
                          .collection("vaccines")
                          .doc(vaccine.id)
                            .delete();
                    }, icon: Icon(Icons.delete_forever,color: Colors.red,))
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
import 'dart:convert';
import 'dart:ui';

import 'package:CryingBaby/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import '../../model/Child.dart';
import '../../model/ChildVaccines.dart';
import '../../model/SharedData.dart';
import '../../utils.dart';

class Home extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class UpcomingChildVaccines {
  Child child;
  ChildVaccines childVaccines;

  UpcomingChildVaccines(this.child,this.childVaccines);
}

class _HomePage extends State<Home> {

  List<Child> children = [];
  List<ChildVaccines> allChildVaccines = [];
  List<UpcomingChildVaccines> upcomingVaccines = [];


  @override
  void initState() {
    super.initState();

    loadChildren();

  }

  void loadChildren() async{
    upcomingVaccines.clear();
    allChildVaccines.clear();
    children.clear();

    Stream<List<Child>> childrenStram = getChildren();
    Stream<List<ChildVaccines>> vaccinesStram = getChildVaccines();
    List<Child> allchildren = [];
    List<ChildVaccines> allVaccines = [];
    childrenStram.listen((event) {
      allchildren = event;

      vaccinesStram.listen((event2) {
        allVaccines = event2;

        for(Child child in allchildren){
          if(child.userKey == SharedData.currentUser.id){
            children.add(child);
            for(ChildVaccines vaccines in allVaccines){
              if(vaccines.childKey == child.id && vaccines.state == 0){
                allChildVaccines.add(vaccines);
              }
            }
          }
        }

        allChildVaccines.sort(
                (a,b){
              DateTime firstDate = DateTime.parse(a.date);
              DateTime secondDate = DateTime.parse(b.date);
              return firstDate.compareTo(secondDate);
            }
        );

        for(Child child in children){
          ChildVaccines vv = getChildVaccine(child);
          if(vv.state > -1){
            List<ChildVaccines> allDayVaccines = getChildVaccineDate(child, vv.date);
            for(ChildVaccines cVaccine in allDayVaccines) {
              UpcomingChildVaccines upcomingChildVaccines = UpcomingChildVaccines(child, cVaccine);
              upcomingVaccines.add(upcomingChildVaccines);
            }
          }
        }


        setState(() {

        });
      });
    });






  }


  ChildVaccines getChildVaccine(Child child){
    for(ChildVaccines vaccines in allChildVaccines){
      if(vaccines.childKey == child.id){
        return vaccines;
      }
    }
    return ChildVaccines(childKey: "-1", vaccine: "vaccine", date: "date", state: -1,image: "");
  }

  List<ChildVaccines> getChildVaccineDate(Child child,String date){
    List<ChildVaccines> allDayVaccines = [];
    for(ChildVaccines vaccines in allChildVaccines){
      if(vaccines.childKey == child.id && vaccines.date == date){
        allDayVaccines.add(vaccines);
      }
    }
    return allDayVaccines;
  }


  Stream<List<Child>> getChildren() => FirebaseFirestore.instance
      .collection("childs")
      .snapshots()
      .map((event) => event.docs.map((e) => Child.fromJson(e.data())).toList());


  Stream<List<ChildVaccines>> getChildVaccines() => FirebaseFirestore.instance
      .collection("child_vaccines")
      .snapshots()
      .map((event) => event.docs.map((e) => ChildVaccines.fromJson(e.data())).toList());


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: RefreshIndicator(
        onRefresh: (){
          return Future.delayed(
              Duration(seconds: 1),
                  (){
                loadChildren();
              }
          );
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
            width: double.infinity,
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [

                    Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text( "مرحبا " ,style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            )),
                            Image.asset(
                              'assets/smile_face.png',
                              fit: BoxFit.cover,
                              height: 30,
                              width: 30,
                            )
                          ],
                        ),
                        Text(SharedData.currentUser.name,style: SafeGoogleFont (
                        'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      )),
                      ]
                    ),),


                  ],
                ),

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text('التطعيمات القادمة',
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
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: upcomingVaccines.length,
                              itemBuilder: (context, indexS) {
                                String childName = upcomingVaccines[indexS].child.name;
                                String date = upcomingVaccines[indexS].childVaccines.date;
                                String vaccineName = upcomingVaccines[indexS].childVaccines.vaccine;

                                return Card(
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
                                    child: Row(
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
                                                  Text(childName,
                                                      style: SafeGoogleFont(
                                                        'Roboto',
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.1725,
                                                        color: primary)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(vaccineName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.fade,
                                                        style: SafeGoogleFont(
                                                            'Roboto',
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w700,
                                                            height: 1.1725,
                                                            color: Colors.black)),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(date,
                                                      style: SafeGoogleFont(
                                                          'Roboto',
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w700,
                                                          height: 1.1725,
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                )




              ],
            ),
          ),
        ),
      ),
    );
  }


}
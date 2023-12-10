

import 'package:CryingBaby/model/Child.dart';
import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/page-1/admin/add_vaccine.dart';
import 'package:CryingBaby/page-1/admin/edit_vaccine.dart';
import 'package:CryingBaby/page-1/user/child_drugs_list.dart';
import 'package:CryingBaby/page-1/user/child_vaccines_list.dart';
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
import 'add_child.dart';




class TabChilds extends StatefulWidget {
  @override
  _TabChilds createState() => _TabChilds();
}

class _TabChilds extends State<TabChilds> {

  List<Child> children = [];

  @override
  void initState(){
    super.initState();
  //  loadVaccines();
  }

  void loadVaccines() async{
    children=[];
    Stream<List<Child>> vaccinesStram = getChildren();
    List<Child> allchildren = await vaccinesStram.first;
    for(Child child in allchildren){
      if(child.userKey == SharedData.currentUser.id){
        children.add(child);
      }
    }
    setState((){

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<Child>> getChildren() => FirebaseFirestore.instance
      .collection("childs")
      .where("userKey",isEqualTo: SharedData.currentUser.id)
      .snapshots()
      .map((event) => event.docs.map((e) => Child.fromJson(e.data())).toList());


  @override
  Widget build(BuildContext context) {



        return Scaffold(

          body: RefreshIndicator(
            onRefresh: (){
              return Future.delayed(
                  Duration(seconds: 1),
                      (){
                    print('Reloaded');
                  }
              );
            },
            child: SingleChildScrollView(
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
                                          Text('قائمة الأبناء',
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
                              child: StreamBuilder<List<Child>>(
                                stream: getChildren(),
                                builder: (context,snapshot){
                                  if(snapshot.hasError){
                                    return Text("Something went wrong");
                                  }else if(snapshot.hasData){
                                    children = snapshot.data!;
                                    return ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: children.length,
                                        itemBuilder: (context, indexS) {

                                          return buildVaccine(children[indexS]);
                                        });
                                  }else{
                                    return Center(child: CircularProgressIndicator(),);
                                  }
                                },

                              ),
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
          floatingActionButton: FloatingActionButton(
            heroTag: UniqueKey(),
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder:(context) => AddChild()));

            },
          ),
        );

  }

  Widget buildVaccine(Child vaccine) => Container(
    child: GestureDetector(
      onTap: (){
        SharedData.currentChild = vaccine;
        Navigator.of(context).push(MaterialPageRoute(
            builder:(context) => ChildVaccinesList()));
      },
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
                  child: Text(vaccine.birth_date ,style: SafeGoogleFont (
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
                        SharedData.currentChild = vaccine;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder:(context) => ChildDrugsList()));
                      }, icon: Icon(Icons.medication_liquid,color: Colors.green,)),

                      IconButton(onPressed: (){
                        SharedData.currentChild = vaccine;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder:(context) => ChildVaccinesList()));
                      }, icon: Icon(Icons.medical_information,color: primary,)),
                      IconButton(onPressed: (){
                          FirebaseFirestore.instance
                            .collection("childs")
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
    ),
  );


}
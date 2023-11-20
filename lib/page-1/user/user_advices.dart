

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/page-1/admin/add_advice.dart';
import 'package:CryingBaby/page-1/admin/add_notification.dart';
import 'package:CryingBaby/page-1/admin/add_vaccine.dart';
import 'package:CryingBaby/page-1/admin/edit_notification.dart';
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
import '../../model/Advices.dart';
import '../../model/SharedData.dart';
import '../../model/Messages.dart';
import 'package:http/http.dart' as http;

import '../../utils.dart';


class TabUserAdvices extends StatefulWidget {
  @override
  _TabUserAdvices createState() => _TabUserAdvices();
}

class _TabUserAdvices extends State<TabUserAdvices> {



  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<Advices>> getAdvices() => FirebaseFirestore.instance
      .collection("advices")
      .snapshots()
      .map((event) => event.docs.map((e) => Advices.fromJson(e.data())).toList());


  @override
  Widget build(BuildContext context) {



    return Scaffold(

      body: SingleChildScrollView(

        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              StreamBuilder<List<Advices>>(
                  stream: getAdvices(),
                  builder: (context,snapshot){
                    if(snapshot.hasError){
                      return Text("Something went wrong");
                    }
                    else if(snapshot.hasData){
                      final advices = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: advices.length,
                        itemBuilder: (context,index){
                          return buildAdvices(advices[index]);
                        },
                      );

                    }else{
                      return Center(child: CircularProgressIndicator(),);
                    }
                  })

            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: SharedData.userType == 0,
        child: FloatingActionButton(
          heroTag: UniqueKey(),
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder:(context) => AddAdvice()));

          },
        ),
      ),
    );
  }

  Widget buildAdvices(Advices advices) => Container(
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

            Visibility(
              visible: advices.image != "",
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Image.network(advices.image,height: 200,),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(advices.title ,style: SafeGoogleFont (
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
                child: Text(advices.description ,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1725,
                  color: Colors.black,
                )),
              ),
            ),

          ],
        ),
      ),
    ),
  );


}
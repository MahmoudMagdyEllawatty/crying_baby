

import 'package:CryingBaby/model/MonthStatics.dart';
import 'package:CryingBaby/page-1/admin/add_advice.dart';
import 'package:CryingBaby/page-1/admin/add_notification.dart';
import 'package:CryingBaby/page-1/admin/add_vaccine.dart';
import 'package:CryingBaby/page-1/admin/edit_notification.dart';
import 'package:CryingBaby/page-1/admin/edit_vaccine.dart';
import 'package:CryingBaby/page-1/user/add_question.dart';
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
import '../../model/Question.dart';
import '../../model/SharedData.dart';
import '../../model/Messages.dart';
import 'package:http/http.dart' as http;

import '../../utils.dart';
import '../../widget/CustomColorSelectionHandle.dart';


class TabQuestions extends StatefulWidget {
  @override
  _TabQuestions createState() => _TabQuestions();
}

class _TabQuestions extends State<TabQuestions> {



  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<Question>> getAdvices() => FirebaseFirestore.instance
      .collection("questions")
      .snapshots()
      .map((event) => event.docs.map((e) => Question.fromJson(e.data())).toList());


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

              StreamBuilder<List<Question>>(
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
        visible: SharedData.userType == 1,
        child: FloatingActionButton(
          heroTag: UniqueKey(),
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder:(context) => AddQuestion()));

          },
        ),
      ),
    );
  }

  Widget buildAdvices(Question advices) => Container(
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
                child: Text(advices.question ,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.1725,
                  color: primary,
                )),
              ),
            ),
            Visibility(
              visible: advices.answer != "",
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Text(advices.answer ,style: SafeGoogleFont (
                    'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1725,
                    color: Colors.black,
                  )),
                ),
              ),
            ),
            Visibility(
              visible: advices.answer == "" && SharedData.userType == 0,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Card(
                    elevation: 10,
                    child: Column(
                        children: [
                          Material(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: TextField(
                              selectionControls: CustomColorSelectionHandle(Colors.transparent),
                              keyboardType: TextInputType.text,
                              onChanged: (value){
                                advices.answer = value;
                              },
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
                                  hintText: "الرد"
                              ) ,
                              style: SafeGoogleFont (
                                'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: primary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),

                            child: Text("إرسال الرد",style: SafeGoogleFont (
                              'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),),
                            onPressed: () async {
                              final docVaccine = FirebaseFirestore.instance
                                  .collection("questions")
                                  .doc(advices.id);


                              final json = advices.toJson();

                              await docVaccine.set(json);

                            },
                          )
                        ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                child: Text(advices.userName+" "+advices.date ,style: SafeGoogleFont (
                  'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1725,
                  color: Colors.grey,
                )),
              ),
            ),


          ],
        ),
      ),
    ),
  );


}
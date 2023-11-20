

import 'package:CryingBaby/model/MonthStatics.dart';
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
import '../../model/SharedData.dart';
import '../../model/Messages.dart';
import 'package:http/http.dart' as http;

import '../../utils.dart';


class TabNotifications extends StatefulWidget {
  @override
  _TabNotifications createState() => _TabNotifications();
}

class _TabNotifications extends State<TabNotifications> {



  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<List<Messages>> getNotifications() => FirebaseFirestore.instance
      .collection("notifications")
      .snapshots()
      .map((event) => event.docs.map((e) => Messages.fromJson(e.data())).toList());


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

              StreamBuilder<List<Messages>>(
                  stream: getNotifications(),
                  builder: (context,snapshot){
                    if(snapshot.hasError){
                      return Text("Something went wrong");
                    }
                    else if(snapshot.hasData){
                      final messages = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context,index){
                          return buildMessage(messages[index]);
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
                builder:(context) => AddNotification()));

          },
        ),
      ),
    );
  }

  Widget buildMessage(Messages message) => Container(
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
                child: Text(message.title ,style: SafeGoogleFont (
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
                child: Text(message.description ,style: SafeGoogleFont (
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
                      SharedData.message = message;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder:(context) => EditNotification()));
                    }, icon: Icon(Icons.edit_outlined,color: primary,)),
                    IconButton(onPressed: (){
                      FirebaseFirestore.instance
                          .collection("notifications")
                          .doc(message.id)
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
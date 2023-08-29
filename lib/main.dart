import 'package:attendance_app/page-1/log-in.dart';
import 'package:attendance_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'controller/requirement_state_controller.dart';



// import 'package:myapp/page-1/home.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		Get.put(RequirementStateController());
	return MaterialApp(
		title: 'Flutter',
		debugShowCheckedModeBanner: false,
		scrollBehavior: MyCustomScrollBehavior(),
		theme: ThemeData(
		primarySwatch: Colors.blue,
		),
		home: Scaffold(
		body: SingleChildScrollView(
			child: Login(),
		),
		),
	);
	}
}

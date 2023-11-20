import 'package:CryingBaby/colors.dart';
import 'package:CryingBaby/page-1/login.dart';
import 'package:CryingBaby/page-1/old-log-in.dart';
import 'package:CryingBaby/page-1/splash.dart';
import 'package:CryingBaby/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'controller/requirement_state_controller.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
// import 'package:myapp/page-1/home.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	await Firebase.initializeApp(
		options: DefaultFirebaseOptions.currentPlatform,
	);
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		Get.put(RequirementStateController());



	return MaterialApp(
			localizationsDelegates: [
				AppLocalizations.delegate,
				GlobalMaterialLocalizations.delegate,
				GlobalWidgetsLocalizations.delegate,
				GlobalCupertinoLocalizations.delegate,
			],

		supportedLocales: [
			const Locale('en'),
			const Locale('ar'),
		],
		localeResolutionCallback: (deviceLocale, supportedLocales) {
			for (var locale in supportedLocales) {
				if (locale.languageCode == deviceLocale!.languageCode &&
						locale.countryCode == deviceLocale.countryCode) {
					return deviceLocale;
				}
			}
			return supportedLocales.last;
		},
		title: 'Flutter',
		debugShowCheckedModeBanner: false,
		scrollBehavior: MyCustomScrollBehavior(),
		theme: ThemeData(
		primarySwatch: primary,
		),
		home: Scaffold(
			resizeToAvoidBottomInset: false,
		body: SingleChildScrollView(
			child: Splash(),
		),
		),
	);
	}
}

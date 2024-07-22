import 'package:flutter/material.dart';
import 'package:flutter_study/screen/list_view_screen.dart';
import 'package:flutter_study/screen/main_screen.dart';
import 'package:flutter_study/screen/navigator_screen.dart';
import 'package:flutter_study/screen/navigator_sub_screen.dart';
import 'package:flutter_study/screen/set_state_screen.dart';
import 'package:flutter_study/screen/splash_screen.dart';
import 'package:flutter_study/screen/text_field_screen.dart';
import 'package:flutter_study/screen/value_notifier_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/', // 최초 이동 화면
      routes: {
        '/': (context) => SplashScreen(),
        '/main' : (context)  => NavigatorScreen(),
        '/sub' : (context) => NavigatorSubScreen(),
      },
    );
  }
}
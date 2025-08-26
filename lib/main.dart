import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:live/screen/activate.dart';
import 'package:live/screen/live_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_pr;
import 'package:shared_preferences/shared_preferences.dart';


late SharedPreferences shared_pr;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  shared_pr = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Streaming',
      // theme: ThemeData(
      //   textTheme: ThemeData.light().textTheme.apply(fontFamily: 'myfont'),
      // ),
      theme:ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'myfont')
      ),
      home: ActivationScreen(),
    );
  }
}

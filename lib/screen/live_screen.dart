import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:live/dev.dart';
import 'package:live/screen/device.dart';
import 'package:live/screen/dshow.dart';
import 'package:live/screen/files.dart';
import 'package:live/screen/function.dart';
import 'package:live/screen/link.dart';
import 'package:live/screen/viewvid.dart';

class LiveStreamingScreen extends StatefulWidget {
  const LiveStreamingScreen({Key? key}) : super(key: key);

  @override
  _LiveStreamingScreenState createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopStreaming();
    DeleteAllFiles(PARENT_DIR);
  }

  @override
  void initState() {
    super.initState();
    // for (String s in CHANNELS_MAP.values) {
    //   Directory d = Directory(s);
    //   if (!d.existsSync()) {
    //     d.createSync(recursive: true);
    //   }
    // }
  }

  // المتغير الذي سيحدد نوع البث المختار
  String selectedOption = "link";

  Widget liveType() {
    if (selectedOption == "link")
      return Link();
    else if (selectedOption == "file")
      return Files();
    else if (selectedOption == "device")
      return Device();
    else
      return CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        animationDuration: Duration(seconds: 2),
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: () {
              setState(() {
                
              });
            }, icon: Icon(Icons.refresh)),
            title: Text('Live Streaming App'),
            centerTitle: true,
            bottom: TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                tabs: [
                  Tab(
                    text: "البث",
                  ),
                  Tab(
                    text: "العرض",
                  )
                ]),
          ),
          body: TabBarView(children: [
           
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RadioListTile(
                      activeColor: Colors.green,
                      title: Text(
                        "البث بواسطة الرابط",
                        textAlign: TextAlign.center,
                      ),
                      value: "link",
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      activeColor: Colors.green,
                      title: Text(
                        "البث بواسطة ملف",
                        textAlign: TextAlign.center,
                      ),
                      value: "file",
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      activeColor: Colors.green,
                      title: Text(
                        "البث بواسطة جهاز",
                        textAlign: TextAlign.center,
                      ),
                      value: "device",
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    liveType(),
                  //  Device()
                  ],
                ),
              ),
            ),
             Container(
              child: DeviceSelector2view(),
             ),
          ]),
          bottomNavigationBar: BottomAppBar(
            elevation: 2,
            height: 40,
            color: Colors.black,
            child: Center(child: Text("برمجه: إبراهيم الجداوي",style: TextStyle(color: Colors.white),)),
          ),
        ));
  }
}

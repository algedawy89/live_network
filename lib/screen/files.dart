import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as filepk;
import 'package:live/conf/conf.dart';
import 'package:live/main.dart';
import 'package:live/screen/function.dart';

class Files extends StatefulWidget {
  const Files({Key? key}) : super(key: key);

  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {
  TextEditingController textcontroller = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String selectedResolution = '1280x720';
  bool isStreaming = false;
  String output = PARENT_DIR + OUTPUTPATH;
  String frameInfo = ""; // لإظهار معدل الإطارات والمعلومات الأخرى
  Process? process;
  String? channel;

  String? theChannel;

  Future<void> picFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'wav'],
        allowMultiple: false);

    if (result != null && result.files.isNotEmpty) {
      String filepath = result.files.single.path!;
      if (File(filepath).existsSync()) {
        textcontroller.text = filepath;
      } else {
        Errordialog("الملف غير موجود", context);
      }
    }
  }

  void startStreamingDevice() async {
    bool? dletete = false;
    if (Directory(channel!).existsSync()) {
      dletete = await showConfirmDialog(
          context: context,
          title: "خطأ",
          message: " هذا المجلد مشغول حاليا هل تريد حذف محتوياته",
          yesButtonText: "نعم",
          noButtonText: "لا");

      if (!dletete!) {
        Directory(channel!).deleteSync();
      }
    }

    if (formkey.currentState!.validate()) {
      setState(() {
        isStreaming = true;
        frameInfo = "Starting stream...";
      });

      try {
        if (shared_pr.getString("resolution")!.isNotEmpty ||
            shared_pr.getString("resolution") != null) {
          selectedResolution = shared_pr.getString("resolution")!;
        } else {
          selectedResolution = '640x360';
        }

        output = createdirectory(channel!);

        theChannel = findKeyByValue(CHANNELS_MAP, channel!);

        List<String> arguments = [
          '-re',
          "-i",
          textcontroller.text,
          '-vf',
          'scale=$selectedResolution',
          "-c:v",
          "libx264",
          "-c:a",
          "aac",
          "-f",
          "hls",
          '-hls_time',
          '4',
          '-hls_list_size',
          '4',
          '-hls_segment_filename',
          '${output}_%03d.ts',
          output
        ];

        process = await Process.start(FFMPEG_PATH, arguments);
        process!.stdout.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            frameInfo = data;
          });
        });

        process!.stderr.transform(SystemEncoding().decoder).listen((data) {
          setState(() {
            frameInfo = data;
          });
        });

        process!.exitCode.then((code) {
          if (code != 0) {
            setState(() {
              frameInfo = 'Error: Process exited with code $code';
              isStreaming = false;
            });
          }
        });
      } catch (e) {
        Errordialog('Error running FFmpeg: $e', context);
        setState(() {
          frameInfo = 'Error running FFmpeg';
          isStreaming = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    channel = CHANNELS_MAP.values.first;
    if (selectedResolution != null || selectedResolution.isNotEmpty) {
      print(selectedResolution);
    } else {
      selectedResolution = '426x240';
    }
  }

  bool isstart = true;

  @override
  void dispose() {
    stopStreaming(
        p: process,
        isStreaming: isStreaming,
        variable: frameInfo,
        isChannel: channel != null,
        channel: channel,
        msgInfo: "stopstreaming");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Form(
              key: formkey,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        readOnly: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "يجب ان تختار ملف فيديو اولا";
                          } else
                            return null;
                        },
                        textAlign: TextAlign.left,
                        controller: textcontroller,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  IconButton(onPressed: picFile, icon: Icon(Icons.file_upload))
                ],
              )),
          SizedBox(
            height: 40,
          ),
          // CircularProgressIndicator(),
          ResluationDropDown(selectedResolution: selectedResolution),

          SizedBox(
            height: 40,
          ),
          // if (isstart)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChannelDropDown(onChanged: (val) {
                channel = val;
              }),
            ],
          ),
          SizedBox(
            height: 40,
          ),

          ElevatedButton(
            onPressed: isStreaming ? null : startStreamingDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(
                  width: 3,
                ),
                Text('Start Streaming'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isStreaming
                ? () {
                    stopStreaming(
                        p: process,
                        isStreaming: isStreaming,
                        variable: frameInfo,
                        isChannel: channel != null,
                        channel: channel,
                        msgInfo: "stopstreaming");

                    setState(() {
                      isStreaming = false;
                      isstart = true;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop_outlined),
                SizedBox(
                  width: 3,
                ),
                Text('Stop Streaming'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isStreaming)

          StreamVia('Streaming is active... via', ' file ',  ' on channel:', ' ${theChannel}')
             ,
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(width: 1, color: Colors.green),
                borderRadius: BorderRadius.circular(12)),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Text(
              frameInfo,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

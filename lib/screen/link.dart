import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:live/conf/conf.dart';
import 'package:live/main.dart';
import 'package:live/screen/function.dart';

class Link extends StatefulWidget {
  const Link({Key? key}) : super(key: key);

  @override
  _LinkState createState() => _LinkState();
}

class _LinkState extends State<Link> {
  TextEditingController textcontroller = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String selectedResolution = '1280x720';
  bool isStreaming = false;
  String output = PARENT_DIR + OUTPUTPATH;
  String frameInfo = ""; // لإظهار معدل الإطارات والمعلومات الأخرى
  Process? process;
  String channel = CHANNELS_MAP.values.first;
  String? theChannel;

  String segementSelect = "4";
  List<String> segmentslist = [
    '1',
    '2',
    '4',
    '6',
    '8',
    '10',
    '12',
    '14',
    '16',
    '18',
    '20',
    '22',
    '24',
    '26',
    '28',
    '30',
  ];

  String selectedListgroup = "4";

  List<String> listgrouplist = ['2', '4', '6', '8', '10'];

  @override
  void initState() {
    selectedResolution = RESOLUATION.contains('1280x720 (HD)')
        ? '1280x720 (HD)'
        : RESOLUATION.first;
    super.initState();
  }

  void startStreamingDevice() async {
    if (formkey.currentState!.validate()) {
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

      setState(() {
        isStreaming = true;
        frameInfo = "Starting stream...";
      });

      output = createdirectory(channel);
      try {
        if (shared_pr.getString("resolution")!.isNotEmpty ||
            shared_pr.getString("resolution") != null) {
          selectedResolution = shared_pr.getString("resolution")!;
        } else {
          selectedResolution = '640x360';
        }

        String segment;
        String group;

        if (shared_pr.getString("group")!.isNotEmpty ||
            shared_pr.getString("group") != null) {
          group = shared_pr.getString("group")!;
        } else {
          group = selectedListgroup;
        }

        if (shared_pr.getString("segment")!.isNotEmpty ||
            shared_pr.getString("segment") != null) {
          segment = shared_pr.getString("segment")!;
        } else {
          segment = segementSelect;
        }

        output = createdirectory(channel);
        theChannel = findKeyByValue(CHANNELS_MAP, channel!);
        List<String> arguments = [
          '-re',
          '-i',
          textcontroller.text,
          '-vf',
          'scale=$selectedResolution',
          '-c:v',
          'libx264',
          '-c:a',
          'aac',
          '-af',
          'aresample=async=1',
          '-fps_mode',
          'vfr',
          '-fflags',
          '+genpts',
          '-f',
          'hls',
          '-hls_time',
          segment,
          '-hls_list_size',
          group,
          '-hls_segment_filename',
          '${output}_%03d.ts',
          output,
        ];
        // بدء عملية FFmpeg
        process = await Process.start(FFMPEG_PATH, arguments);
        process!.stdout.transform(SystemEncoding().decoder).listen((data) {
          // تحديث النص بالمعلومات الجديدة
          setState(() {
            frameInfo = data;
          });
        });

        process!.stderr.transform(SystemEncoding().decoder).listen((data) {
          // معالجة الأخطاء
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

  // void stopStreaming() {
  //   process?.kill();
  //   DeleteAllFiles(PARENT_DIR);
  //   setState(() {
  //     isStreaming = false;
  //     frameInfo = "Streaming stopped.";
  //   });
  // }

  @override
  void dispose() {
    stopStreaming(
        p: process,
        isStreaming: isStreaming,
        variable: frameInfo,
        isChannel: channel != null,
        channel: channel,
        msgInfo: "stopstreaming");

    DeleteAllFiles(PARENT_DIR);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // قسم إدخال الرابط
        Card(
          elevation: 4,
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "إعدادات البث",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                // اختيار القناة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tv, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "اختر القناة",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    TvLinkDropdown(controller: textcontroller),
                  ],
                ),
                const SizedBox(height: 20),
                // حقل إدخال الرابط
                Form(
                  key: formkey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "يجب ان تضع الرابط أولا";
                      }
                      return null;
                    },
                    controller: textcontroller,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      label: const Text(
                        "الصق الرابط هنا",
                        style: TextStyle(color: Colors.white70),
                      ),
                      prefixIcon: const Icon(Icons.link, color: Colors.green),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // إعدادات البث
        Card(
          elevation: 4,
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "خيارات البث",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    // زمن التقطيع
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cut, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text("زمن التقطيع"),
                          const SizedBox(width: 8),
                          SegmentDropdown(controller: segementSelect),
                        ],
                      ),
                    ),

                    // عدد العناصر
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.numbers, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text("العناصر/المجموعة"),
                          const SizedBox(width: 8),
                          GroupDropdown(controller: selectedListgroup),
                        ],
                      ),
                    ),

                    // الدقة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.high_quality, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text("الدقة"),
                          const SizedBox(width: 8),
                          ResluationDropDown(selectedResolution: selectedResolution),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // اختيار القناة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_tree, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text("قناة البث"),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChannelDropDown(
                          onChanged: (val) => channel = val,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // أزرار التحكم
        Card(
          elevation: 4,
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isStreaming)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: StreamVia(
                      'البث جارٍ... عبر',
                      ' link ',
                      ' على القناة:',
                      ' ${theChannel}',
                    ),
                  ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isStreaming
                          ? () {
                              stopStreaming(
                                p: process,
                                isStreaming: isStreaming,
                                variable: frameInfo,
                                isChannel: channel != null,
                                channel: channel,
                                msgInfo: "stopstreaming",
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stop),
                          SizedBox(width: 8),
                          Text('إيقاف البث'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: isStreaming ? null : startStreamingDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text('بدء البث'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // معلومات البث
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(width: 1, color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            frameInfo,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
}

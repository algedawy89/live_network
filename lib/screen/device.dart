import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:live/conf/conf.dart';
import 'package:live/main.dart';
import 'package:live/screen/function.dart';

class Device extends StatefulWidget {
  const Device({Key? key}) : super(key: key);

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  final _localRenderer = RTCVideoRenderer();

  List<MediaDeviceInfo> videoDevices = [];
  List<MediaDeviceInfo> audioDevices = [];
  MediaDeviceInfo? videselect; // استخدام nullable بدلاً من late
  MediaDeviceInfo? audioselect; // استخدام nullable بدلاً من late

  bool isStreaming = false;
  String output = PARENT_DIR + OUTPUTPATH;
  String? channel = CHANNELS_MAP.values.first;

  String selectedResolution = '1280x720';
  String selectedValue = "";

  String frameInfo = ""; // لإظهار معدل الإطارات والمعلومات الأخرى
  Process? process;

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

  String selectedListgroup = "0";

  List<String> listgrouplist = ['2', '4', '6', '8', '10'];
  String? theChannel;

  // تهيئة المكونات البصرية
  void _initRenderers() async {
    await _localRenderer.initialize();
  }

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

  // الحصول على الأجهزة المتاحة (كاميرات وميكروفونات)
  void _getDevices() async {
    try {
      final videoDevicesList = await navigator.mediaDevices.enumerateDevices();
      final videoList = videoDevicesList
          .where((device) => device.kind == 'videoinput')
          .toList();
      setState(() {
        videoDevices = videoList;
        // تهيئة videselect بعد تحميل الأجهزة
        if (videoDevices.isNotEmpty) {
          videselect = videoDevices[0];
        }
      });

      final audioList = videoDevicesList
          .where((device) => device.kind == 'audioinput')
          .toList();
      setState(() {
        audioDevices = audioList;
        // تهيئة audioselect بعد تحميل الأجهزة
        if (audioDevices.isNotEmpty) {
          audioselect = audioDevices[0];
        }
      });
    } catch (e) {
      print('Error getting devices: $e');
    }
  }

  void startStreamingDevice() async {
    // Ensure devices are selected
    if (videselect == null || audioselect == null) {
      print('Video or Audio device not selected!');
      return;
    }

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

    // Run FFmpeg process
    try {
//  '-async',
//         '1',
//         '-vsync',
//         '1',

//  '-af',
//   'aresample=async=1',
//   '-fps_mode',
//   'vfr',
//   '-fflags',
//   '+genpts',

      // Construct FFmpeg arguments

//بدون تحسين

// List<String> arguments = [
//   '-f', 'dshow',
//   '-i', 'video=${videselect!.label}',  // جهاز الفيديو
//   '-f', 'dshow',
//   '-i', 'audio=${audioselect!.label}',  // جهاز الصوت
//   '-s', setResluation(selectedResolution)!, // دقة الفيديو
//   '-vcodec', 'libx264',
//   '-acodec', 'aac',
//   '-preset', 'ultrafast',
//   '-crf', '20',
//   '-af', 'aresample=async=1',
//   '-fps_mode', 'vfr',
//   '-fflags', '+genpts',
//   '-rtbufsize', '1500M',
//   '-f', 'hls',  // صيغة HLS
//   '-hls_time', '4', // طول كل جزء (segment) بالثواني
//   '-hls_list_size', '5', // عدد الأجزاء في ملف القائمة
//   '-hls_flags', 'delete_segments', // حذف الأجزاء القديمة لتقليل الحجم
//   '-hls_segment_filename', '${output}_%03d.ts', // تسمية ملفات الأجزاء
//   output  // ملف قائمة التشغيل (stream.m3u8)
// ];

      // output =
      // "C:\\Users\\jeddawi\\Desktop\\LiveStram\\live\\html\\temp\\output.m3u8";
// تحسين تزامن الصوت والصوره
      // List<String> arguments = [
      //   '-rtbufsize', '1500M',
      //   '-f', 'dshow',
      //   '-i', 'video=${videselect!.label}', // جهاز الفيديو
      //   '-f', 'dshow',
      //   '-i', 'audio=${audioselect!.label}', // جهاز الصوت
      //   '-s', setResluation(selectedResolution)!, // دقة الفيديو
      //   '-vcodec', 'libx264',
      //   '-acodec', 'aac',
      //   '-preset', 'ultrafast',
      //   '-crf', '20',
      //   '-af', 'aresample=async=1',
      //   '-async', '1', // مزامنة الصوت
      //   '-vsync', '2', // مزامنة الإطارات
      //   '-fps_mode', 'vfr',
      //   '-fflags', '+genpts',

      //   '-f', 'hls',
      //   '-hls_time', segementSelect,
      //   '-hls_list_size', '5',
      //   '-hls_flags', 'delete_segments',
      //   '-hls_segment_filename', '${output}_%03d.ts',
      //   output // ملف قائمة التشغيل (stream.m3u8)
      // ];

      String video;
      String audio;
      
      output = createdirectory(channel!);

     String segment;
      String group;


      if (shared_pr.getString("group")!.isNotEmpty ||
          shared_pr.getString("group") != null) {
        group = shared_pr.getString("resolution")!;
      } else {
        group = selectedListgroup;
      }

      if (shared_pr.getString("segment")!.isNotEmpty ||
          shared_pr.getString("segment") != null) {
        segment = shared_pr.getString("segment")!;
      } else {
        segment = segementSelect;
      }

      if (shared_pr.getString("videoDev")!.isNotEmpty ||
          shared_pr.getString("videoDev") != null) {
        video = shared_pr.getString("videoDev")!;
      } else {
        video = videselect!.label;
      }

      if (shared_pr.getString("audioDev")!.isNotEmpty ||
          shared_pr.getString("audioDev") != null) {
        audio = shared_pr.getString("audioDev")!;
      } else {
        audio = videselect!.label;
      }

      if (shared_pr.getString("resolution")!.isNotEmpty ||
          shared_pr.getString("resolution") != null) {
        selectedResolution = shared_pr.getString("resolution")!;
      }

      theChannel = findKeyByValue(CHANNELS_MAP, channel!);

      List<String> arguments = [
        '-f',
        'dshow',
        '-i',
        'video=${video}', // اسم جهاز الفيديو
        '-f',
        'dshow',
        '-i',
        'audio=${audio}', // اسم جهاز الصوت
        '-use_wallclock_as_timestamps',
        '1',
        '-async',
        '1', // مزامنة الصوت
        '-vsync',
        '1', // مزامنة الفيديو
        '-s',
        selectedResolution, // دقة الفيديو المطلوبة
        '-vcodec',
        'libx264',
        '-acodec',
        'aac',
        '-preset',
        'ultrafast',
        '-crf',
        '20',
        '-pix_fmt',
        'yuv420p',
        '-f',
        'hls',
        '-hls_time',
        segment,
        '-hls_list_size',
        group,
        '-hls_segment_filename',
        '${output}_%03d.ts',
        output // ملف M3U8 النهائي
      ];

//لا يستخدم hls
      // List<String> arguments = [
      //   '-f',
      //   'dshow',
      //   '-i',
      //   'video=${videselect!.label}',
      //   '-f',
      //   'dshow',
      //   '-i',
      //   'audio=${audioselect!.label}',
      //   '-s',
      //   setResluation(selectedResolution)!,
      //   '-vcodec',
      //   'libx264',
      //   '-acodec',
      //   'aac',
      //   '-preset',
      //   'ultrafast',
      //   '-crf',
      //   '20',
      //   '-f',
      //   'segment',
      //   '-segment_time',
      //   '10',
      //   '-af',
      //   'aresample=async=1',
      //   '-fps_mode',
      //   'vfr',
      //   '-fflags',
      //   '+genpts',
      //   '-rtbufsize',
      //   '2000M',
      //   '-segment_list',
      //   output,
      //   '-segment_format',
      //   'mpegts',
      //   '${output}_%03d.ts',
      // ];
      // Errordialog(videselect!.label + audioselect!.label, context);

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

  // void stopStreaming() {
  //   DeleteAllFiles(PARENT_DIR);
  //   process?.kill();
  //   setState(() {
  //     isStreaming = false;
  //     frameInfo = "Streaming stopped.";
  //   });

  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initRenderers();
    _getDevices();
    selectedResolution = RESOLUATION.contains('1280x720 (HD)')
        ? '1280x720 (HD)'
        : RESOLUATION.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 2, color: Colors.green)),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100,
                      ),
                      Container(
                          child: SegmentDropdown(
                        controller: segementSelect,
                      )),
                      SizedBox(
                        width: 30,
                      ),
                      Text("زمن تقطيع الفيديو"),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.cut),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          child: GroupDropdown(controller: selectedListgroup)),
                      SizedBox(
                        width: 30,
                      ),
                      Text("عدد العناصر في المجموعه الواحدة"),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.numbers),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (videselect != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Align(
                            alignment: Alignment.center,
                            child: DeviceDropdown(
                              type: 'video',
                              devices: videoDevices,
                              selected_device: videselect,
                            )),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text("جهاز اخراج الفيديو"),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.video_file)
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                if (audioselect != null)
                  SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Align(
                              alignment: Alignment.center,
                              child: DeviceDropdown(
                                type: 'audio',
                                devices: audioDevices,
                                selected_device: audioselect,
                              )),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text("جهاز اخراج الصوت"),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.audio_file)
                      ],
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      child: Align(
                          alignment: Alignment.center,
                          child: ResluationDropDown(
                              selectedResolution: selectedResolution)),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    Text("الدقه"),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.high_quality_outlined)
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      child: Align(
                          alignment: Alignment.center,
                          child: ChannelDropDown(onChanged: (value) {
                            channel = value;
                          })),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    Text("القناه"),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.high_quality_outlined)
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isStreaming)
                StreamVia('Streaming is active... via', ' device ',  ' on channel:', ' ${theChannel}'),
                SizedBox(
                  width: 50,
                ),
                ElevatedButton(
                  onPressed: isStreaming
                      ? () {
                          setState(() {
                            isStreaming = false;
                          });
                          stopStreaming(
                              p: process,
                              isStreaming: isStreaming,
                              variable: frameInfo,
                              isChannel: channel != null,
                              channel: channel,
                              msgInfo: "stopstreaming");
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
                SizedBox(
                  width: 20,
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
              ],
            ),
          ),
          const SizedBox(width: 20),
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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:live/conf/conf.dart';
import 'package:live/main.dart';

const String PARENT_DIR = "html\\temp\\";
const String OUTPUTPATH = "output.m3u8";
const String FFMPEG_PATH = "ffmpeg.exe";

//ffmpeg\\bin\\

void Errordialog(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("Error")
              ],
            ),
            content: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(height: 500, child: Text(message)),
                  ],
                ),
              ),
            ),
          ));
}

void stopProcessWithTaskkill(int pid) async {
  try {
    // تشغيل أمر taskkill مع PID
    final result =
        await Process.run('taskkill', ['/PID', pid.toString(), '/F']);
    if (result.exitCode == 0) {
      print("Process $pid killed successfully.");
    } else {
      print("Failed to kill process $pid. Error: ${result.stderr}");
    }
  } catch (e) {
    print("Error while killing process: $e");
  }
}

Future<bool?> showConfirmDialog({
  required BuildContext context,
  Widget? icon,
  required String title,
  required String message,
  required String yesButtonText,
  required String noButtonText,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              icon,
              SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              noButtonText,
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              yesButtonText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

void stopStreaming(
    {bool? isChannel = false,
    String? channel,
    Process? p,
    bool? isStreaming = false,
    String? variable = "",
    String? msgInfo}) async {
  if (p != null && p.pid != null) {
    stopProcessWithTaskkill(p.pid);
  }
  sleep(Duration(seconds: 1));

  variable = msgInfo;
  if (isChannel!) {
    await DeleteAllFiles(channel!, deletepar: true);
  } else {
    await DeleteAllFiles(PARENT_DIR);
  }

  // List<String> arguments = ['/f', '/im', 'ffmpeg.exe'];

  // try {
  //   // Run the FFmpeg process
  //   final result = await Process.run("taskkill", arguments);

  //   if (result.exitCode == 0) {
  //     print('Streaming started successfully!');
  //     sleep(Duration(seconds: 1));
  //     await DeleteAllFiles(PARENT_DIR);
  //   } else {
  //     print('Error starting stream: ${result.stderr}');
  //   }
  // } catch (e) {
  //   print('Error running FFmpeg: $e');
  // }
}

Future<void> DeleteAllFiles(String directory, {bool deletepar = false}) async {
  Directory d = Directory(directory);
  if (await d.exists()) {
    if (deletepar) {
      d.deleteSync(recursive: true);
    } else {
      final files = await d.listSync();
      for (var f in files) {
        f.delete(recursive: true);
      }
    }
  }
}

final RESOLUATION = [
  '1920x1080 (Full HD)',
  '1280x720 (HD)',
  '854x480 (SD)',
  '640x360 (Low)',
  '320x240 (Very Low)',
  '426x240 (Very Very Low)',
];

final tvLink = {
  'scs 1': 'http://www.technomaster.pro/hls/cIlchannel1-stream.m3u8',
  'scs 2': 'http://www.technomaster.pro/hls/cIlchannel2-stream.m3u8',
  'scs 3': 'http://www.technomaster.pro/hls/cIlchannel3-stream.m3u8',
  'scs 4': 'http://www.technomaster.pro/hls/cIlchannel4-stream.m3u8',
  'scs 5': 'http://www.technomaster.pro/hls/cIlchannel5-stream.m3u8',
  'BEIN SPORT 1 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12499.m3u8',
  'BEIN SPORT 2 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12500.m3u8',
  'BEIN SPORT 3 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12501.m3u8',
  'BEIN SPORT 4 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12502.m3u8',
  'BEIN SPORT 5 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12503.m3u8',
  'BEIN SPORT 6 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12504.m3u8',
  'BEIN SPORT 7 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12505.m3u8',
  'BEIN SPORT 8 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12506.m3u8',
  'BEIN SPORT 9 FHD H265':
      'http://nvpro.tv:80/live/999764664/666646898/12507.m3u8',
  'BEIN SPORTS 1 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32855.m3u8',
  'BEIN SPORTS 2 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32854.m3u8',
  'BEIN SPORTS 3 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32853.m3u8',
  'BEIN SPORTS 4 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32852.m3u8',
  'BEIN SPORTS 5 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32851.m3u8',
  'BEIN SPORTS 6 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32850.m3u8',
  'BEIN SPORTS 7 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32849.m3u8',
  'BEIN SPORTS 8 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32848.m3u8',
  'BEIN SPORTS 9 POWER':
      'http://nvpro.tv:80/live/999764664/666646898/32847.m3u8',
  'BEIN SPORT 1 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15933.m3u8',
  'BEIN SPORT 2 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15934.m3u8',
  'BEIN SPORT 3 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15935.m3u8',
  'BEIN SPORT 4 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15936.m3u8',
  'BEIN SPORT 5 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15937.m3u8',
  'BEIN SPORT 6 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15938.m3u8',
  'BEIN SPORT 7 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15939.m3u8',
  'BEIN SPORT 8 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15940.m3u8',
  'BEIN SPORT 9 H265 HD':
      'http://nvpro.tv:80/live/999764664/666646898/15941.m3u8',
};

class TvLinkDropdown extends StatefulWidget {
  @override
  TextEditingController controller;
  TvLinkDropdown({required this.controller});
  _TvLinkDropdownState createState() => _TvLinkDropdownState();
}

class _TvLinkDropdownState extends State<TvLinkDropdown> {
  String? selectedLink = tvLink['BEIN SPORT 1 H265 HD'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 40, 68, 41)),
      child: DropdownButton<String>(
        hint: Text("Select TV Link"),
        value: selectedLink,
        onChanged: (String? newValue) {
          setState(() {
            selectedLink = newValue;
            if (selectedLink != null || selectedLink!.isNotEmpty) {
              widget.controller.text = selectedLink!;
            }
          });
        },
        items: tvLink.keys.map<DropdownMenuItem<String>>((String key) {
          return DropdownMenuItem<String>(
            value: tvLink[key],
            child: Text(key),
          );
        }).toList(),
      ),
    );
  }
}

final SEGMENT_LIST = [
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

class SegmentDropdown extends StatefulWidget {
  @override
  String controller;
  SegmentDropdown({required this.controller});
  _SegmentDropdownState createState() => _SegmentDropdownState();
}

class _SegmentDropdownState extends State<SegmentDropdown> {
  String? segment = SEGMENT_LIST[3];

  @override
  void initState() {
    // TODO: implement initState
    if (widget.controller.isEmpty) {
      widget.controller = SEGMENT_LIST[3];
    } else {
      shared_pr.setString(Conf.segment.toString(), widget.controller);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 40, 68, 41)),
      child: DropdownButton<String>(
        hint: Text("Select TV Link"),
        value: segment,
        onChanged: (String? newValue) {
          setState(() {
            segment = newValue;
            if (segment != null || segment!.isNotEmpty) {
              widget.controller = segment!;
              shared_pr.setString(Conf.segment.toString(), segment!);
            }
          });
        },
        items: SEGMENT_LIST.map<DropdownMenuItem<String>>((String key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Text(key),
          );
        }).toList(),
      ),
    );
  }
}

String createdirectory(String channel) {
  Directory d = Directory(channel!);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
    return channel! + OUTPUTPATH;
  } else {
    return channel! + OUTPUTPATH;
  }
}

Widget StreamVia(String span1, String span2, String span3, String span4,
    {Color? ofspan1, Color? ofspan2}) {
  return Row(
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: span1,
              style: TextStyle(color: ofspan1 ?? Colors.green),
            ),
            TextSpan(
              text: span2,
              style: TextStyle(color: ofspan2 ?? Colors.white),
            ),
            TextSpan(
              text: span3,
              style: TextStyle(color: ofspan1 ?? Colors.green),
            ),
            TextSpan(
              text: span4,
              style: TextStyle(color: ofspan2 ?? Colors.white),
            ),
          ],
        ),
      ),
    ],
  );
}

String findKeyByValue(Map<String, String> map, String value) {
  // البحث عن المفتاح باستخدام القيمة
  return map.entries
      .firstWhere((entry) => entry.value == value,
          orElse: () => MapEntry('', ''))
      .key;
}

final Map<String, String> CHANNELS_MAP = {
  'channel_one': 'html\\temp\\ch1\\',
  'channel_two': 'html\\temp\\ch2\\',
  'channel_three': 'html\\temp\\ch3\\',
  'channel_four': 'html\\temp\\ch4\\',
  'channel_five': 'html\\temp\\ch5\\',
  'channel_six': 'html\\temp\\ch6\\',
};

class ChannelDropDown extends StatefulWidget {
  final ValueChanged<String> onChanged;

  ChannelDropDown({
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ChannelDropDownState createState() => _ChannelDropDownState();
}

class _ChannelDropDownState extends State<ChannelDropDown> {
  String? select_channel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text("تحديث"),
                  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: Icon(Icons.refresh)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 40, 68, 41)),
              child: DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 33, 70, 34),
                alignment: Alignment.center,
                style: const TextStyle(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
                focusColor: const Color.fromARGB(254, 7, 27, 7),
                value: select_channel ?? CHANNELS_MAP.values.first,
                onChanged: (String? newValue) {
                  if (newValue != null && newValue.isNotEmpty) {
                    setState(() {
                      select_channel = newValue;
                      widget
                          .onChanged(newValue); // استدعاء الدالة لتحديث القيمة
                    });
                  }
                },
                items: CHANNELS_MAP.keys
                    .map<DropdownMenuItem<String>>((String key) {
                  bool directoryExists =
                      Directory(CHANNELS_MAP[key]!).existsSync();
                  return DropdownMenuItem<String>(
                    value: CHANNELS_MAP[key].toString(),
                    child: Text(
                      key,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: directoryExists
                            ? Colors.red
                            : const Color.fromARGB(255, 255, 254, 254),
                      ),
                    ),
                    enabled: !directoryExists,
                    onTap: () {
                      if (directoryExists) {
                        Errordialog("هذا المجلد غير متاح", context);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final LIST_GROUP = ['2', '4', '6', '8', '10'];

class GroupDropdown extends StatefulWidget {
  @override
  String controller;
  GroupDropdown({required this.controller});
  _GroupDropdownState createState() => _GroupDropdownState();
}

class _GroupDropdownState extends State<GroupDropdown> {
  String? group = LIST_GROUP[1];

  @override
  void initState() {
    // TODO: implement initState
    if (widget.controller.isEmpty) {
      widget.controller = SEGMENT_LIST[1];
    } else {
      shared_pr.setString(Conf.group.toString(), widget.controller);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 40, 68, 41)),
      child: DropdownButton<String>(
        hint: Text("Select TV Link"),
        value: group,
        onChanged: (String? newValue) {
          setState(() {
            group = newValue;
            if (group != null || group!.isNotEmpty) {
              shared_pr.setString(Conf.group.toString(), group!);
              widget.controller = group!;
            }
          });
        },
        items: LIST_GROUP.map<DropdownMenuItem<String>>((String key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Text(key),
          );
        }).toList(),
      ),
    );
  }
}

class DeviceDropdown extends StatefulWidget {
  final List<MediaDeviceInfo> devices;
  MediaDeviceInfo? selected_device;
  final String type;
  DeviceDropdown(
      {required this.type,
      this.selected_device,
      required this.devices,
      Key? key})
      : super(key: key);

  @override
  _DeviceDropdownState createState() => _DeviceDropdownState();
}

class _DeviceDropdownState extends State<DeviceDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 40, 68, 41)),
      child: DropdownButton<MediaDeviceInfo>(
        dropdownColor: const Color.fromARGB(255, 33, 70, 34),
        alignment: Alignment.center,
        style: TextStyle(),
        borderRadius: BorderRadius.circular(12),
        focusColor: const Color.fromARGB(254, 7, 27, 7),
        value: widget.selected_device,
        onChanged: (MediaDeviceInfo? newValue) {
          setState(() {
            if (widget.type == 'video') {
              shared_pr.setString(Conf.videoDev.toString(), newValue!.label);
            }
            if (widget.type == 'audio') {
              shared_pr.setString(Conf.audioDev.toString(), newValue!.label);
            }
            widget.selected_device = newValue!;
          });
        },
        items: widget.devices.map<DropdownMenuItem<MediaDeviceInfo>>(
          (MediaDeviceInfo value) {
            return DropdownMenuItem<MediaDeviceInfo>(
              value: value,
              child: Text(value.label ?? 'Unknown Device'),
            );
          },
        ).toList(),
      ),
    );
  }
}

// String? setResluation(String res) {
//   switch (res) {
//     // case '1920x1080 (Full HD)':
//     //   return "1920x1080";
//     // case '1280x720 (HD)':
//     //   return '1280x720';
//     case '854x480 (SD)':
//       return "854x480";
//     case '640x360 (Low)':
//       return "640x360";
//     case '320x240 (Very Low)':
//       return "320x240";
//     case '426x240 (Very Very Low)':
//       return "426x240";
//   }
// }

final RESOLUATION_MAP = {
  '1920x1080 (Full HD)': '1920x1080',
  '1280x720 (HD)': '1280x720',
  '854x480 (SD)': '854x480',
  '640x360 (640)': '640x360',
  '426x240 (420)': '426x240',
  '320x240 (320)': '320x240',
};

class ResluationDropDown extends StatefulWidget {
  String selectedResolution;

  ResluationDropDown({required this.selectedResolution, Key? key})
      : super(key: key);

  @override
  _ResluationDropDownState createState() => _ResluationDropDownState();
}

class _ResluationDropDownState extends State<ResluationDropDown> {
  String? selectedres;
  @override
  void initState() {
    super.initState();
    selectedres = RESOLUATION_MAP['320x240 (320)'];
    // Ensure a valid default resolution is set
    if (widget.selectedResolution.isEmpty ||
        !RESOLUATION_MAP.containsKey(selectedres)) {
      widget.selectedResolution = '426x240';
    } else {
      shared_pr.setString(
          Conf.resolution.toString(), widget.selectedResolution);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 40, 68, 41)),
      child: DropdownButton<String>(
        dropdownColor: const Color.fromARGB(255, 33, 70, 34),
        alignment: Alignment.center,
        style: const TextStyle(color: Colors.white), // Add default style
        borderRadius: BorderRadius.circular(12),
        focusColor: const Color.fromARGB(254, 7, 27, 7),
        value: selectedres, // Match keys in RESOLUATION_MAP
        onChanged: (String? newValue) {
          selectedres = newValue;

          setState(() {});
          if (selectedres != null || selectedres!.isNotEmpty) {
            widget.selectedResolution = selectedres!;
            shared_pr.setString(Conf.resolution.toString(), selectedres!);
          }
          print('the res is ${shared_pr.get(Conf.resolution.toString())}');

          // if (newValue != null) {
          //   setState(() {
          //     print("the value:$newValue");
          //     // print(RESOLUATION_MAP[newValue]);
          //     widget.selectedResolution = newValue;
          //   });
          // }
        },
        items: RESOLUATION_MAP.keys.map<DropdownMenuItem<String>>((String key) {
          return DropdownMenuItem<String>(
            value: RESOLUATION_MAP[key]
                .toString(), // Use key as value for consistency
            child: Text(
              key,
              overflow: TextOverflow.ellipsis, // Prevent overflow
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Widget resluation(
    {required String selectedResolution, required void Function() setstate}) {
  return DropdownButton<String>(
    dropdownColor: const Color.fromARGB(255, 33, 70, 34),
    alignment: Alignment.center,
    style: const TextStyle(color: Colors.white), // Add default style
    borderRadius: BorderRadius.circular(12),
    focusColor: const Color.fromARGB(254, 7, 27, 7),
    value: selectedResolution, // Match keys in RESOLUATION_MAP
    onChanged: (String? newValue) {
      if (newValue != null) {
        setstate();
        selectedResolution = newValue;
      }
    },
    items: RESOLUATION_MAP.keys.map<DropdownMenuItem<String>>((String key) {
      return DropdownMenuItem<String>(
        value: key, // Use key for value
        child: Text(key),
      );
    }).toList(),
  );
}

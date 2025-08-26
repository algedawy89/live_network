import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player_win/video_player_win.dart';

class Dshow extends StatefulWidget {
  const Dshow({Key? key}) : super(key: key);

  @override
  State<Dshow> createState() => _DeviceState();
}

class _DeviceState extends State<Dshow> {
  final _localRenderer = RTCVideoRenderer();

  List<MediaDeviceInfo> videoDevices = [];
  List<MediaDeviceInfo> audioDevices = [];
  MediaDeviceInfo? selectedVideoDevice;
  MediaDeviceInfo? selectedAudioDevice;

  late WinVideoPlayerController controller;
  bool isControllerInitialized = false;
  bool isStreaming = false;
  String outputPath = "dshow\\output.m3u8";
  String selectedResolution = '1280x720';
  String segmentDuration = "4";
  String selectedListGroup = "4";

  List<String> segmentsList = ['1', '2', '4', '6', '8', '10', '12'];
  List<String> listGroupList = ['2', '4', '6', '8', '10'];
  List<String> resolutions = ['640x480', '1280x720', '1920x1080'];

  String frameInfo = "";
  Process? process;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _getDevices();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> initializeVideoPlayer(String filePath) async {
    if (await File(filePath).exists()) {
      controller = WinVideoPlayerController.file(File(filePath));

      try {
        await controller.initialize();
        setState(() {
          isControllerInitialized = true;
          controller.play();
        });
      } catch (e) {
        print("Error initializing video player: $e");
      }
    } else {
      print("File does not exist: $filePath");
    }
  }

  void _getDevices() async {
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      setState(() {
        videoDevices = devices.where((d) => d.kind == 'videoinput').toList();
        audioDevices = devices.where((d) => d.kind == 'audioinput').toList();
        if (videoDevices.isNotEmpty) selectedVideoDevice = videoDevices[0];
        if (audioDevices.isNotEmpty) selectedAudioDevice = audioDevices[0];
      });
    } catch (e) {
      print('Error getting devices: $e');
    }
  }

  void startStreaming() async {
    if (selectedVideoDevice == null || selectedAudioDevice == null) {
      print('Please select both video and audio devices.');
      return;
    }

    setState(() {
      isStreaming = true;
      frameInfo = "Starting stream...";
    });

    try {
      List<String> arguments = [
        '-f',
        'dshow',
        '-i',
        'video=${selectedVideoDevice!.label}',
        '-f',
        'dshow',
        '-i',
        'audio=${selectedAudioDevice!.label}',
        '-s',
        selectedResolution,
        '-vcodec',
        'libx264',
        '-acodec',
        'aac',
        '-preset',
        'ultrafast',
        '-crf',
        '20',
        '-af',
        'aresample=async=1',
        '-async',
        '1',
        '-vsync',
        '2',
        '-fps_mode',
        'vfr',
        '-fflags',
        '+genpts',
        '-rtbufsize',
        '1500M',
        '-f',
        'hls',
        '-hls_time',
        segmentDuration,
        '-hls_list_size',
        '5',
        '-hls_flags',
        'delete_segments',
        '-hls_segment_filename',
        '${outputPath}_%03d.ts',
        outputPath,
      ];

      process = await Process.start('ffmpeg', arguments);
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

      await Future.delayed(Duration(seconds: 5));
      initializeVideoPlayer(outputPath);
    } catch (e) {
      print("Error starting streaming: $e");
      setState(() {
        frameInfo = 'Error running FFmpeg';
        isStreaming = false;
      });
    }
  }

  void stopStreaming() {
    process?.kill();
    setState(() {
      isStreaming = false;
      frameInfo = "Streaming stopped.";
    });
  }

  @override
  void dispose() {
    stopStreaming();
    controller.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Streaming")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
          
                  SizedBox(
                    height: 20,
                  ),
                  if (selectedVideoDevice != null)
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
                            child: DropdownButton<MediaDeviceInfo>(
                              dropdownColor:
                                  const Color.fromARGB(255, 33, 70, 34),
                              alignment: Alignment.center,
                              style: TextStyle(),
                              borderRadius: BorderRadius.circular(12),
                              focusColor: const Color.fromARGB(254, 7, 27, 7),
                              value: selectedVideoDevice,
                              onChanged: (MediaDeviceInfo? newValue) {
                                setState(() {
                                  selectedVideoDevice = newValue!;
                                });
                              },
                              items: videoDevices
                                  .map<DropdownMenuItem<MediaDeviceInfo>>(
                                (MediaDeviceInfo value) {
                                  return DropdownMenuItem<MediaDeviceInfo>(
                                    value: value,
                                    child: Text(value.label ?? 'Unknown Device'),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
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
                  if (selectedAudioDevice != null)
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
                              child: DropdownButton<MediaDeviceInfo>(
                                dropdownColor:
                                    const Color.fromARGB(255, 33, 70, 34),
                                alignment: Alignment.center,
                                style: TextStyle(),
                                borderRadius: BorderRadius.circular(12),
                                focusColor: const Color.fromARGB(254, 7, 27, 7),
                                value: selectedAudioDevice,
                                onChanged: (MediaDeviceInfo? newValue) {
                                  setState(() {
                                    selectedAudioDevice = newValue!;
                                  });
                                },
                                items: audioDevices
                                    .map<DropdownMenuItem<MediaDeviceInfo>>(
                                  (MediaDeviceInfo value) {
                                    return DropdownMenuItem<MediaDeviceInfo>(
                                      value: value,
                                      child: Text(value.label ?? 'Unknown Device'),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
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
          
              DropdownButton<String>(
                value: segmentDuration,
                items: segmentsList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    segmentDuration = newValue!;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedResolution,
                items: resolutions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedResolution = newValue!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: isStreaming ? stopStreaming : startStreaming,
                child: Text(isStreaming ? "Stop Streaming" : "Start Streaming"),
              ),
              if (isControllerInitialized)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: WinVideoPlayer(controller),
                ),
              Text(frameInfo),
            ],
          ),
        ),
      ),
    );
  }
}

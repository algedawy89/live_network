import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GetDevices {
  final _localRenderer = RTCVideoRenderer();
  List<MediaDeviceInfo> videoDevices = [];
  List<MediaDeviceInfo> audioDevices = [];

  GetDevices() {
    _initRenderers();
  }
  void _initRenderers() async {
    await _localRenderer.initialize();
    getDevices();
  }

  void getDevices() async {
    try {
      // الحصول على الأجهزة الفيديو المتاحة
      final videoDevicesList = await navigator.mediaDevices.enumerateDevices();
      final videoList = videoDevicesList
          .where((device) => device.kind == 'videoinput')
          .toList();

      videoDevices = videoList;

      // الحصول على الأجهزة الصوتية المتاحة
      final audioList = videoDevicesList
          .where((device) => device.kind == 'audioinput')
          .toList();

      audioDevices = audioList;
    } catch (e) {
      print('Error getting devices: $e');
    }
  }
}

class DeviceSelector extends StatefulWidget {
  @override
  _DeviceSelectorState createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  final _localRenderer = RTCVideoRenderer();
  List<MediaDeviceInfo> videoDevices = [];
  List<MediaDeviceInfo> audioDevices = [];

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _getDevices();
    print(videoDevices.length);
  }

  // تهيئة المكونات البصرية
  void _initRenderers() async {
    await _localRenderer.initialize();
  }

  // الحصول على الأجهزة المتاحة (كاميرات وميكروفونات)
  void _getDevices() async {
    try {
      // الحصول على الأجهزة الفيديو المتاحة
      final videoDevicesList = await navigator.mediaDevices.enumerateDevices();
      final videoList = videoDevicesList
          .where((device) => device.kind == 'videoinput')
          .toList();
      setState(() {
        videoDevices = videoList;
      });

      // الحصول على الأجهزة الصوتية المتاحة
      final audioList = videoDevicesList
          .where((device) => device.kind == 'audioinput')
          .toList();
      setState(() {
        audioDevices = audioList;
      });
    } catch (e) {
      print('Error getting devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Devices Selection')),
      body: Column(
        children: [
          ListTile(
            title: Text('Video Devices'),
            subtitle: Text(videoDevices.isEmpty
                ? 'No video devices available'
                : 'Available video devices:'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Select Video Device'),
                    content: Column(
                      children: videoDevices
                          .map((device) => ListTile(
                                title: Text(device.label),
                                subtitle: Text(device.label),
                                onTap: () {
                                  // اختيار جهاز الفيديو
                                  print(
                                      'Selected video device: ${device.label}');
                                  Navigator.pop(context);
                                },
                              ))
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Audio Devices'),
            subtitle: Text(audioDevices.isEmpty
                ? 'No audio devices available'
                : 'Available audio devices:'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Select Audio Device'),
                    content: Column(
                      children: audioDevices
                          .map((device) => ListTile(
                                title: Text(device.label),
                                subtitle: Text(device.label),
                                onTap: () {
                                  // اختيار جهاز الصوت
                                  print(
                                      'Selected audio device: ${device.label}');
                                  Navigator.pop(context);
                                },
                              ))
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
          Container(
            width: double.infinity,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }
}

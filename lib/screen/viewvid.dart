import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';



class DeviceSelector2view extends StatefulWidget {
  @override
  _DeviceSelectorState createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector2view> {
  List<MediaDeviceInfo> _videoDevices = [];
  List<MediaDeviceInfo> _audioDevices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedVideoDeviceId;
  String? _selectedAudioDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      
      setState(() {
        _videoDevices = devices.where((device) => device.kind == 'videoinput').toList();
        _audioDevices = devices.where((device) => device.kind == 'audioinput').toList();
        _isLoading = false;
        
        // تحديد أول جهاز فيديو وصوت افتراضيًا
        if (_videoDevices.isNotEmpty) {
          _selectedVideoDeviceId = _videoDevices.first.deviceId;
        }
        if (_audioDevices.isNotEmpty) {
          _selectedAudioDeviceId = _audioDevices.first.deviceId;
        }
      });
    } catch (e) {
      print('Error loading devices: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحميل الأجهزة: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  void _filterDevices(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<MediaDeviceInfo> _getFilteredVideoDevices() {
    if (_searchQuery.isEmpty) {
      return _videoDevices;
    }
    return _videoDevices.where((device) => 
      device.label.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<MediaDeviceInfo> _getFilteredAudioDevices() {
    if (_searchQuery.isEmpty) {
      return _audioDevices;
    }
    return _audioDevices.where((device) => 
      device.label.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _startStreaming() {
    if (_selectedVideoDeviceId == null && _selectedAudioDeviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار جهاز فيديو أو صوت على الأقل'))
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoDisplayScreen(
          videoDeviceId: _selectedVideoDeviceId,
          audioDeviceId: _selectedAudioDeviceId,
          videoDevices: _videoDevices,
          audioDevices: _audioDevices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر أجهزة الفيديو والصوت'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevices,
            tooltip: 'تحديث الأجهزة',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط البحث
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'بحث عن جهاز',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterDevices,
                  ),
                ),
                
                // أجهزة الفيديو
                Expanded(
                  child: ListView(
                    children: [
                      if (_getFilteredVideoDevices().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'أجهزة الفيديو (${_getFilteredVideoDevices().length})',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      
                      ..._getFilteredVideoDevices().map((device) => DeviceCard(
                        device: device,
                        icon: Icons.videocam,
                        isSelected: _selectedVideoDeviceId == device.deviceId,
                        onTap: () {
                          setState(() {
                            _selectedVideoDeviceId = device.deviceId;
                          });
                        },
                      )),
                      
                      if (_getFilteredAudioDevices().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Text(
                            'أجهزة الصوت (${_getFilteredAudioDevices().length})',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      
                      ..._getFilteredAudioDevices().map((device) => DeviceCard(
                        device: device,
                        icon: Icons.mic,
                        isSelected: _selectedAudioDeviceId == device.deviceId,
                        onTap: () {
                          setState(() {
                            _selectedAudioDeviceId = device.deviceId;
                          });
                        },
                      )),
                      
                      if (_getFilteredVideoDevices().isEmpty && _getFilteredAudioDevices().isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.device_unknown, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد أجهزة مطابقة للبحث',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // زر البدء
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.play_arrow),
                      label: Text('بدء البث'),
                      onPressed: _startStreaming,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDevices,
        child: Icon(Icons.refresh),
        tooltip: 'تحديث القائمة',
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final MediaDeviceInfo device;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Colors.blue[50] : null,
      child: ListTile(
        leading: Icon(icon, size: 32, color: isSelected ? Colors.blue : null),
        title: Text(
          device.label.isNotEmpty ? device.label : 'جهاز بدون اسم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('النوع: ${device.kind == 'videoinput' ? 'فيديو' : 'صوت'}'),
          ],
        ),
        trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
        onTap: onTap,
      ),
    );
  }
}

class VideoDisplayScreen extends StatefulWidget {
  final String? videoDeviceId;
  final String? audioDeviceId;
  final List<MediaDeviceInfo> videoDevices;
  final List<MediaDeviceInfo> audioDevices;

  const VideoDisplayScreen({
    Key? key,
    required this.videoDeviceId,
    required this.audioDeviceId,
    required this.videoDevices,
    required this.audioDevices,
  }) : super(key: key);

  @override
  _VideoDisplayScreenState createState() => _VideoDisplayScreenState();
}

class _VideoDisplayScreenState extends State<VideoDisplayScreen> {
  final RTCVideoRenderer _videoRenderer = RTCVideoRenderer();
  MediaStream? _mediaStream;
  bool _isLoading = true;
  bool _isPlaying = false;
  double _volume = 1.0;
  bool _isFullscreen = false;
  String? _currentVideoDeviceId;
  String? _currentAudioDeviceId;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    
    // إضافة مستمع لأزرار الأجهزة
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // الخروج من وضع ملء الشاشة عند الضغط على زر ESC
      if (event.logicalKey == LogicalKeyboardKey.escape && _isFullscreen) {
        _toggleFullscreen();
      }
      
      // مسافة للتحكم في التشغيل/الإيقاف
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlayPause();
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoRenderer.initialize();
      await _startDeviceStreaming();

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _currentVideoDeviceId = widget.videoDeviceId;
        _currentAudioDeviceId = widget.audioDeviceId;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تشغيل الجهاز: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _startDeviceStreaming() async {
    try {
      final constraints = <String, dynamic>{
        'audio': widget.audioDeviceId != null ? {
          'deviceId': widget.audioDeviceId
        } : false,
        'video': widget.videoDeviceId != null ? {
          'deviceId': widget.videoDeviceId,
          'width': 1280,
          'height': 720,
          'frameRate': 30
        } : false
      };

      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      
      setState(() {
        _mediaStream = stream;
        _videoRenderer.srcObject = stream;
      });

    } catch (e) {
      print('Error starting stream: $e');
      throw e;
    }
  }

  Future<void> _switchDevice({String? videoDeviceId, String? audioDeviceId}) async {
    _stopStreaming();
    
    setState(() {
      _isLoading = true;
      _currentVideoDeviceId = videoDeviceId ?? _currentVideoDeviceId;
      _currentAudioDeviceId = audioDeviceId ?? _currentAudioDeviceId;
    });

    try {
      final constraints = <String, dynamic>{
        'audio': _currentAudioDeviceId != null ? {
          'deviceId': _currentAudioDeviceId
        } : false,
        'video': _currentVideoDeviceId != null ? {
          'deviceId': _currentVideoDeviceId,
          'width': 1280,
          'height': 720,
          'frameRate': 30
        } : false
      };

      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      
      setState(() {
        _mediaStream = stream;
        _videoRenderer.srcObject = stream;
        _isLoading = false;
      });

    } catch (e) {
      print('Error switching device: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تغيير الجهاز: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  void _togglePlayPause() {
    if (_mediaStream != null) {
      setState(() {
        _isPlaying = !_isPlaying;
      });

      if (_isPlaying) {
        _mediaStream!.getTracks().forEach((track) => track.enabled = true);
      } else {
        _mediaStream!.getTracks().forEach((track) => track.enabled = false);
      }
    }
  }

  void _stopStreaming() {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => track.stop());
      _videoRenderer.srcObject = null;
    }
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      // الخروج من وضع ملء الشاشة
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      // الدخول إلى وضع ملء الشاشة
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
  }

  // دالة مساعدة للحصول على اسم الجهاز من معرفه
  String _getDeviceName(String? deviceId, List<MediaDeviceInfo> devices) {
    if (deviceId == null) return 'لا يوجد';
    
    try {
      final device = devices.firstWhere((d) => d.deviceId == deviceId);
      return device.label.isNotEmpty ? device.label : 'جهاز بدون اسم';
    } catch (e) {
      return 'غير معروف';
    }
  }

  void _showDeviceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تغيير الأجهزة'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (widget.videoDevices.isNotEmpty) ...[
                Text('أجهزة الفيديو:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...widget.videoDevices.map((device) => ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text(device.label.isNotEmpty ? device.label : 'جهاز بدون اسم'),
                  trailing: _currentVideoDeviceId == device.deviceId 
                      ? Icon(Icons.check, color: Colors.blue) 
                      : null,
                  onTap: () {
                    _switchDevice(videoDeviceId: device.deviceId);
                    Navigator.pop(context);
                  },
                )),
                Divider(),
              ],
              
              if (widget.audioDevices.isNotEmpty) ...[
                Text('أجهزة الصوت:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...widget.audioDevices.map((device) => ListTile(
                  leading: Icon(Icons.mic),
                  title: Text(device.label.isNotEmpty ? device.label : 'جهاز بدون اسم'),
                  trailing: _currentAudioDeviceId == device.deviceId 
                      ? Icon(Icons.check, color: Colors.blue) 
                      : null,
                  onTap: () {
                    _switchDevice(audioDeviceId: device.deviceId);
                    Navigator.pop(context);
                  },
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(
        title: Text('عرض البث المباشر'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.switch_video),
            onPressed: _showDeviceSelectionDialog,
            tooltip: 'تغيير الجهاز',
          ),
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: 'ملء الشاشة',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          if (_isFullscreen) {
            _toggleFullscreen();
            return false;
          }
          return true;
        },
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  // عرض الفيديو
                  Center(
                    child: _mediaStream != null
                        ? RTCVideoView(_videoRenderer)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'لا يوجد بث فعال',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                  ),
                  
                  // عناصر التحكم (تظهر عند التمرير)
                  if (!_isFullscreen) _buildControlPanel(),
                  
                  // زر الخروج من وضع ملء الشاشة
                  if (_isFullscreen) Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: _toggleFullscreen,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.fullscreen_exit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // معلومات الأجهزة
            Row(
              children: [
                Icon(Icons.info, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'فيديو: ${_getDeviceName(_currentVideoDeviceId, widget.videoDevices)} | صوت: ${_getDeviceName(_currentAudioDeviceId, widget.audioDevices)}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // عناصر التحكم الرئيسية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip: _isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                ),
                IconButton(
                  icon: Icon(Icons.stop, color: Colors.white, size: 30),
                  onPressed: () {
                    _stopStreaming();
                    Navigator.pop(context);
                  },
                  tooltip: 'إيقاف',
                ),
                IconButton(
                  icon: Icon(
                    _volume > 0.5 ? Icons.volume_up : 
                    _volume > 0 ? Icons.volume_down : Icons.volume_mute, 
                    color: Colors.white, 
                    size: 30
                  ),
                  onPressed: () {
                    // عرض عناصر تحكم الصوت
                  },
                  tooltip: 'الصوت',
                ),
                IconButton(
                  icon: Icon(Icons.switch_video, color: Colors.white, size: 30),
                  onPressed: _showDeviceSelectionDialog,
                  tooltip: 'تغيير الجهاز',
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.white, size: 30),
                  onPressed: _toggleFullscreen,
                  tooltip: 'ملء الشاشة',
                ),
              ],
            ),
            
            // شريط تحكم الصوت
            Row(
              children: [
                Icon(Icons.volume_mute, color: Colors.white, size: 20),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: _changeVolume,
                    activeColor: Colors.blue,
                  ),
                ),
                Icon(Icons.volume_up, color: Colors.white, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    _stopStreaming();
    _videoRenderer.dispose();
    
    // التأكد من الخروج من وضع ملء الشاشة
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    
    super.dispose();
  }
}
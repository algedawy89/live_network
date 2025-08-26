import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live/screen/live_screen.dart';

class ActivationScreen extends StatefulWidget {
  @override
  _ActivationScreenState createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _activationCodeController =
      TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // الكود المشفر الذي يجب على المستخدم إدخاله (يمكنك تغييره)
  final String _encryptedCode = "O14CANHhwle7wp4JIa3uOQ==";

  @override
  void initState() {
    super.initState();
    _checkActivationStatus();
  }

  // التحقق مما إذا كان التطبيق مفعلًا
  Future<void> _checkActivationStatus() async {
    String? isActivated = await _secureStorage.read(key: 'isActivated');
    if (isActivated == 'true') {
      _navigateToHomeScreen();
    }
  }

  // التحقق من صحة كود التفعيل المدخل
  Future<void> _activateApp() async {
    String enteredCode = _activationCodeController.text.trim();

    if (enteredCode == _encryptedCode) {
      await _secureStorage.write(key: 'isActivated', value: 'true');
      _navigateToHomeScreen();
    } else {
      _showErrorDialog("كود التفعيل غير صحيح");
    }
  }

  // الانتقال إلى الشاشة الرئيسية بعد التفعيل
  void _navigateToHomeScreen() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LiveStreamingScreen()));
  }

  // عرض رسالة خطأ في حال كان الكود خاطئًا
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("حسناً"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("شاشة التفعيل"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _activationCodeController,
              decoration: InputDecoration(
                labelText: 'أدخل كود التفعيل',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _activateApp,
              child: Text("تفعيل"),
            ),
          ],
        ),
      ),
    );
  }
}

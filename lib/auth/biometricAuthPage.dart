import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/services/biometric_service.dart';
import 'package:gcargo/services/auth_service.dart';

class BiometricAuthPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final AuthMethod authMethod;
  final VoidCallback? onFallbackToPin;

  const BiometricAuthPage({
    super.key,
    required this.onSuccess,
    required this.authMethod,
    this.onFallbackToPin,
  });

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  bool isAuthenticating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // เริ่ม authentication ทันทีเมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAuthentication();
    });
  }

  String get _authMethodName {
    switch (widget.authMethod) {
      case AuthMethod.faceId:
        return 'Face ID';
      case AuthMethod.fingerprint:
        return 'ลายนิ้วมือ';
      default:
        return 'ชีวมิติ';
    }
  }

  IconData get _authMethodIcon {
    switch (widget.authMethod) {
      case AuthMethod.faceId:
        return Icons.face;
      case AuthMethod.fingerprint:
        return Icons.fingerprint;
      default:
        return Icons.security;
    }
  }

  Future<void> _startAuthentication() async {
    if (isAuthenticating) return;

    setState(() {
      isAuthenticating = true;
      errorMessage = null;
    });

    BiometricAuthResult result;

    switch (widget.authMethod) {
      case AuthMethod.faceId:
        result = await BiometricService.authenticateWithFaceID();
        break;
      case AuthMethod.fingerprint:
        result = await BiometricService.authenticateWithFingerprint();
        break;
      default:
        result = await BiometricService.authenticateWithAnyBiometric();
    }

    setState(() {
      isAuthenticating = false;
    });

    if (result.success) {
      widget.onSuccess();
    } else {
      setState(() {
        errorMessage = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: kButtonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  _authMethodIcon,
                  color: kButtonColor,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'ยืนยันตัวตนด้วย $_authMethodName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                isAuthenticating 
                    ? 'กำลังตรวจสอบ...'
                    : 'แตะเพื่อใช้ $_authMethodName เข้าสู่ระบบ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),
              
              // Error Message
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Try Again Button
              if (!isAuthenticating && errorMessage != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('ลองใหม่'),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Fallback to PIN button
              if (widget.onFallbackToPin != null)
                TextButton(
                  onPressed: widget.onFallbackToPin,
                  child: const Text('ใช้รหัส PIN แทน'),
                ),
              
              // Loading indicator
              if (isAuthenticating)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

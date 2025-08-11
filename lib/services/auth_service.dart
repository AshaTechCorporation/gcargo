import 'package:shared_preferences/shared_preferences.dart';
import 'package:gcargo/services/biometric_service.dart';

enum AuthMethod { none, pin, faceId, fingerprint }

class AuthService {
  static const String _pinKey = 'user_pin';
  static const String _pinEnabledKey = 'security_pin_enabled';
  static const String _faceIdEnabledKey = 'security_faceid_enabled';
  static const String _fingerprintEnabledKey = 'security_fingerprint_enabled';
  static const String _lastAuthTimeKey = 'last_auth_time';
  static const String _appStateKey = 'app_state';

  // ตรวจสอบว่าต้องการ authentication หรือไม่
  static Future<bool> shouldRequireAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ตรวจสอบว่าเปิดใช้งาน authentication ใดๆ หรือไม่
      final isPinEnabled = prefs.getBool(_pinEnabledKey) ?? true;
      final isFaceIdEnabled = prefs.getBool(_faceIdEnabledKey) ?? false;
      final isFingerprintEnabled = prefs.getBool(_fingerprintEnabledKey) ?? true;

      final hasAnyAuthEnabled = isPinEnabled || isFaceIdEnabled || isFingerprintEnabled;
      if (!hasAnyAuthEnabled) return false;

      // ตรวจสอบว่ามี PIN ตั้งไว้หรือไม่ (ถ้าเปิดใช้ PIN)
      if (isPinEnabled) {
        final hasPin = prefs.getString(_pinKey) != null;
        if (!hasPin) return false;
      }

      // ตรวจสอบว่าแอปถูกปิดแล้วเปิดใหม่หรือไม่
      final appState = prefs.getString(_appStateKey) ?? 'background';
      final lastAuthTime = prefs.getInt(_lastAuthTimeKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // ถ้าแอปอยู่ใน background เกิน 30 วินาที ให้ต้อง auth ใหม่
      if (appState == 'background' && (currentTime - lastAuthTime) > 30000) {
        return true;
      }

      // ถ้าเป็นการเปิดแอปครั้งแรก
      if (appState == 'closed') {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking auth requirement: $e');
      return false;
    }
  }

  // ตรวจสอบว่าควรใช้ biometric หรือ PIN
  static Future<AuthMethod> getPreferredAuthMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFaceIdEnabled = prefs.getBool(_faceIdEnabledKey) ?? false;
      final isFingerprintEnabled = prefs.getBool(_fingerprintEnabledKey) ?? true;
      final isPinEnabled = prefs.getBool(_pinEnabledKey) ?? true;

      // ลำดับความสำคัญ: Face ID > Fingerprint > PIN
      if (isFaceIdEnabled && await BiometricService.hasFaceID()) {
        return AuthMethod.faceId;
      } else if (isFingerprintEnabled && await BiometricService.hasFingerprint()) {
        return AuthMethod.fingerprint;
      } else if (isPinEnabled && await hasPinSet()) {
        return AuthMethod.pin;
      }

      return AuthMethod.none;
    } catch (e) {
      print('Error getting preferred auth method: $e');
      return AuthMethod.pin;
    }
  }

  // บันทึกเวลาที่ auth สำเร็จ
  static Future<void> markAuthSuccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastAuthTimeKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_appStateKey, 'active');
    } catch (e) {
      print('Error marking auth success: $e');
    }
  }

  // บันทึกสถานะแอปเป็น background
  static Future<void> markAppBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, 'background');
    } catch (e) {
      print('Error marking app background: $e');
    }
  }

  // บันทึกสถานะแอปเป็น closed
  static Future<void> markAppClosed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, 'closed');
    } catch (e) {
      print('Error marking app closed: $e');
    }
  }

  // ตรวจสอบว่ามี PIN ตั้งไว้หรือไม่
  static Future<bool> hasPinSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey) != null;
    } catch (e) {
      print('Error checking PIN: $e');
      return false;
    }
  }

  // ตรวจสอบ PIN
  static Future<bool> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString(_pinKey);
      return savedPin == pin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  // บันทึก PIN
  static Future<bool> savePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, pin);
      return true;
    } catch (e) {
      print('Error saving PIN: $e');
      return false;
    }
  }

  // ลบ PIN
  static Future<bool> removePin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      return true;
    } catch (e) {
      print('Error removing PIN: $e');
      return false;
    }
  }

  // ตรวจสอบการตั้งค่าความปลอดภัย
  static Future<Map<String, bool>> getSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'pin_enabled': prefs.getBool(_pinEnabledKey) ?? true,
        'faceid_enabled': prefs.getBool(_faceIdEnabledKey) ?? false,
        'fingerprint_enabled': prefs.getBool(_fingerprintEnabledKey) ?? true,
      };
    } catch (e) {
      print('Error getting security settings: $e');
      return {'pin_enabled': true, 'faceid_enabled': false, 'fingerprint_enabled': true};
    }
  }

  // บันทึกการตั้งค่าความปลอดภัย
  static Future<bool> saveSecuritySetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String prefKey;

      switch (key) {
        case 'pin':
          prefKey = _pinEnabledKey;
          break;
        case 'faceid':
          prefKey = _faceIdEnabledKey;
          break;
        case 'fingerprint':
          prefKey = _fingerprintEnabledKey;
          break;
        default:
          return false;
      }

      await prefs.setBool(prefKey, value);
      return true;
    } catch (e) {
      print('Error saving security setting: $e');
      return false;
    }
  }
}

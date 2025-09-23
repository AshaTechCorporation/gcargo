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
      final isPinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
      final isFaceIdEnabled = prefs.getBool(_faceIdEnabledKey) ?? false;
      final isFingerprintEnabled = prefs.getBool(_fingerprintEnabledKey) ?? false;

      print('🔐 Auth Check - PIN enabled: $isPinEnabled, FaceID: $isFaceIdEnabled, Fingerprint: $isFingerprintEnabled');

      final hasAnyAuthEnabled = isPinEnabled || isFaceIdEnabled || isFingerprintEnabled;
      if (!hasAnyAuthEnabled) {
        print('🔐 No auth enabled, skipping auth');
        return false;
      }

      // ตรวจสอบว่ามี PIN ตั้งไว้หรือไม่ (ถ้าเปิดใช้ PIN)
      if (isPinEnabled) {
        final hasPin = prefs.getString(_pinKey) != null;
        print('🔐 PIN check - has PIN set: $hasPin');
        if (!hasPin) {
          print('🔐 PIN enabled but not set, skipping auth');
          return false;
        }
      }

      // ตรวจสอบว่าแอปถูกปิดแล้วเปิดใหม่หรือไม่
      final appState = prefs.getString(_appStateKey) ?? 'closed';
      final lastAuthTime = prefs.getInt(_lastAuthTimeKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = currentTime - lastAuthTime;

      print('🔐 App state: $appState, time diff: ${timeDiff}ms');

      // ถ้าแอปอยู่ใน background เกิน 30 วินาที ให้ต้อง auth ใหม่
      if (appState == 'background' && timeDiff > 30000) {
        print('🔐 App was in background too long, requiring auth');
        return true;
      }

      // ถ้าเป็นการเปิดแอปครั้งแรก
      if (appState == 'closed') {
        print('🔐 App was closed, requiring auth');
        return true;
      }

      print('🔐 No auth required');
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
      final isFingerprintEnabled = prefs.getBool(_fingerprintEnabledKey) ?? false;
      final isPinEnabled = prefs.getBool(_pinEnabledKey) ?? false;

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

  // บันทึกสถานะแอปเป็น active
  static Future<void> markAppActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, 'active');
      print('🔄 AuthService: App marked as active');
    } catch (e) {
      print('Error marking app active: $e');
    }
  }

  // ลบข้อมูล SharedPreferences ทั้งหมด (สำหรับทดสอบ)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔄 AuthService: Before clear - keys: ${prefs.getKeys()}');
      await prefs.clear();
      print('🔄 AuthService: After clear - keys: ${prefs.getKeys()}');
      print('🔄 AuthService: All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // บันทึกสถานะแอปเป็น background
  static Future<void> markAppBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, 'background');
      await prefs.setInt(_lastAuthTimeKey, DateTime.now().millisecondsSinceEpoch);
      print('🔄 AuthService: App marked as background');
    } catch (e) {
      print('Error marking app background: $e');
    }
  }

  // บันทึกสถานะแอปเป็น closed
  static Future<void> markAppClosed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, 'closed');
      print('🔄 AuthService: App marked as closed');
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
        'pin_enabled': prefs.getBool(_pinEnabledKey) ?? false,
        'faceid_enabled': prefs.getBool(_faceIdEnabledKey) ?? false,
        'fingerprint_enabled': prefs.getBool(_fingerprintEnabledKey) ?? false,
      };
    } catch (e) {
      print('Error getting security settings: $e');
      return {'pin_enabled': false, 'faceid_enabled': false, 'fingerprint_enabled': false};
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

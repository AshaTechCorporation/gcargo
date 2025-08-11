import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // ตรวจสอบว่าอุปกรณ์รองรับ biometric หรือไม่
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  // ตรวจสอบว่ามี biometric ตั้งไว้หรือไม่
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // ดึงรายการ biometric ที่ใช้ได้
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // ตรวจสอบว่ามี Face ID หรือไม่
  static Future<bool> hasFaceID() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face);
    } catch (e) {
      print('Error checking Face ID: $e');
      return false;
    }
  }

  // ตรวจสอบว่ามี Fingerprint หรือไม่
  static Future<bool> hasFingerprint() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      print('Error checking fingerprint: $e');
      return false;
    }
  }

  // ตรวจสอบว่ามี biometric ใดๆ หรือไม่
  static Future<bool> hasAnyBiometric() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking any biometric: $e');
      return false;
    }
  }

  // ทำการ authenticate ด้วย biometric
  static Future<BiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // ตรวจสอบว่าอุปกรณ์รองรับหรือไม่
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricAuthResult(
          success: false,
          errorMessage: 'อุปกรณ์ไม่รองรับการยืนยันตัวตนด้วยชีวมิติ',
        );
      }

      // ตรวจสอบว่ามี biometric ตั้งไว้หรือไม่
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          errorMessage: 'ไม่พบการตั้งค่าชีวมิติในอุปกรณ์',
        );
      }

      // ทำการ authenticate
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return BiometricAuthResult(success: didAuthenticate);
    } on PlatformException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case auth_error.notAvailable:
          errorMessage = 'ไม่พบการตั้งค่าชีวมิติในอุปกรณ์';
          break;
        case auth_error.notEnrolled:
          errorMessage = 'กรุณาตั้งค่าชีวมิติในอุปกรณ์ก่อน';
          break;
        case auth_error.lockedOut:
          errorMessage = 'ถูกล็อคชั่วคราว กรุณาลองใหม่ภายหลัง';
          break;
        case auth_error.permanentlyLockedOut:
          errorMessage = 'ถูกล็อคถาวร กรุณาใช้รหัสผ่านแทน';
          break;
        case auth_error.biometricOnlyNotSupported:
          errorMessage = 'อุปกรณ์ไม่รองรับการยืนยันตัวตนด้วยชีวมิติเท่านั้น';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาดในการยืนยันตัวตน: ${e.message}';
      }

      return BiometricAuthResult(
        success: false,
        errorMessage: errorMessage,
        errorCode: e.code,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'เกิดข้อผิดพลาดที่ไม่คาดคิด: $e',
      );
    }
  }

  // ทำการ authenticate ด้วย Face ID
  static Future<BiometricAuthResult> authenticateWithFaceID() async {
    final hasFace = await hasFaceID();
    if (!hasFace) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'อุปกรณ์ไม่รองรับ Face ID',
      );
    }

    return authenticate(
      reason: 'ใช้ Face ID เพื่อเข้าใช้งาน',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  // ทำการ authenticate ด้วย Fingerprint
  static Future<BiometricAuthResult> authenticateWithFingerprint() async {
    final hasFingerprint = await BiometricService.hasFingerprint();
    if (!hasFingerprint) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'อุปกรณ์ไม่รองรับลายนิ้วมือ',
      );
    }

    return authenticate(
      reason: 'ใช้ลายนิ้วมือเพื่อเข้าใช้งาน',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  // ทำการ authenticate ด้วย biometric ใดๆ ที่มี
  static Future<BiometricAuthResult> authenticateWithAnyBiometric() async {
    final hasAny = await hasAnyBiometric();
    if (!hasAny) {
      return BiometricAuthResult(
        success: false,
        errorMessage: 'อุปกรณ์ไม่รองรับการยืนยันตัวตนด้วยชีวมิติ',
      );
    }

    return authenticate(
      reason: 'ใช้ชีวมิติเพื่อเข้าใช้งาน',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }
}

// คลาสสำหรับเก็บผลลัพธ์การ authenticate
class BiometricAuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  BiometricAuthResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  @override
  String toString() {
    return 'BiometricAuthResult(success: $success, errorMessage: $errorMessage, errorCode: $errorCode)';
  }
}

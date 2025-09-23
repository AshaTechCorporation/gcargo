import 'package:flutter/material.dart';
import 'package:gcargo/auth/biometricAuthPage.dart';
import 'package:gcargo/auth/pinAuthPage.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool isAuthenticated = false;
  bool isLoading = true;
  AuthMethod preferredAuthMethod = AuthMethod.pin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // เมื่อแอปกลับมาจาก background ให้ตรวจสอบ auth ใหม่
      _checkAuthStatus();
    }
  }

  Future<void> _checkAuthStatus() async {
    print('🔍 AuthWrapper: Checking auth status...');
    final shouldAuth = await AuthService.shouldRequireAuth();
    final authMethod = await AuthService.getPreferredAuthMethod();

    print('🔍 AuthWrapper: shouldAuth=$shouldAuth, authMethod=$authMethod');

    setState(() {
      isAuthenticated = !shouldAuth;
      preferredAuthMethod = authMethod;
      isLoading = false;
    });

    print('🔍 AuthWrapper: isAuthenticated=$isAuthenticated');

    // หลังจากตรวจสอบ auth เสร็จแล้ว ให้ mark app เป็น active
    if (!shouldAuth) {
      print('🔍 AuthWrapper: No auth required, marking app as active');
      await AuthService.markAppActive();
    }
  }

  void _onAuthSuccess() {
    AuthService.markAuthSuccess();
    AuthService.markAppActive(); // Mark app as active เมื่อ auth สำเร็จ
    setState(() {
      isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isAuthenticated) {
      // เลือกหน้า auth ตาม preferred method
      switch (preferredAuthMethod) {
        case AuthMethod.faceId:
        case AuthMethod.fingerprint:
          return BiometricAuthPage(
            authMethod: preferredAuthMethod,
            onSuccess: _onAuthSuccess,
            onFallbackToPin: () {
              setState(() {
                preferredAuthMethod = AuthMethod.pin;
              });
            },
          );
        case AuthMethod.pin:
          return PinAuthPage(onSuccess: _onAuthSuccess, isSetup: false);
        case AuthMethod.none:
          // ถ้าไม่มี auth method ให้ไปหน้าหลักเลย
          return const FirstPage();
      }
    }

    return const FirstPage();
  }
}

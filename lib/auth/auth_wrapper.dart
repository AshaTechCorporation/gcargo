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

class _AuthWrapperState extends State<AuthWrapper> {
  bool isAuthenticated = false;
  bool isLoading = true;
  AuthMethod preferredAuthMethod = AuthMethod.pin;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final shouldAuth = await AuthService.shouldRequireAuth();
    final authMethod = await AuthService.getPreferredAuthMethod();

    setState(() {
      isAuthenticated = !shouldAuth;
      preferredAuthMethod = authMethod;
      isLoading = false;
    });
  }

  void _onAuthSuccess() {
    AuthService.markAuthSuccess();
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

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/auth/auth_wrapper.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/firebase_options.dart';
import 'package:gcargo/services/auth_service.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/upgrader_service.dart';
import 'package:gcargo/translations/app_translations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Remove this method to stop OneSignal Debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("5b612135-a020-4fa7-8a95-37aa830870b4");

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Cart Service
  await CartService.init();

  // ✅ Register Controllers ใน GetX dependency injection
  Get.put(LanguageController());
  Get.put(HomeController());

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // แสดงเฉพาะด้านบน ⇒ ด้านล่างถูกซ่อน
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // ⬅️ ADD: ตั้งเวลารี-ซ่อน
  static const _rehideDelay = Duration(milliseconds: 2500);
  Timer? _rehideTimer;

  // ⬅️ ADD: ฟังก์ชันซ่อน “เฉพาะแถบล่าง”
  Future<void> _rehideBottomOnly() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top], // โชว์เฉพาะด้านบน ⇒ ด้านล่างถูกซ่อน
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rehideBottomOnly(); // ⬅️ ADD: ย้ำซ่อนตั้งแต่เริ่ม
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rehideTimer?.cancel(); // ⬅️ ADD
    super.dispose();
  }

  // ⬅️ ADD: เมื่อขนาด/Insets เปลี่ยน (เช่น คีย์บอร์ดขึ้น) ⇒ หน่วงแล้วซ่อนอีกครั้ง
  @override
  void didChangeMetrics() {
    _rehideTimer?.cancel();
    _rehideTimer = Timer(_rehideDelay, _rehideBottomOnly);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // แอปไปอยู่ใน background
        AuthService.markAppBackground();
        break;
      case AppLifecycleState.detached:
        // แอปถูกปิด
        AuthService.markAppClosed();
        break;
      case AppLifecycleState.resumed:
        // แอปกลับมาจาก background - AuthWrapper จะจัดการเอง
        // ⬅️ ADD: กลับเข้าแอป ⇒ ย้ำซ่อนเฉพาะแถบล่าง
        _rehideBottomOnly();
        break;
      case AppLifecycleState.inactive:
        // แอปไม่ active (เช่น มีการแจ้งเตือนมา)
        break;
      case AppLifecycleState.hidden:
        // แอปถูกซ่อน
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ⬅️ ADD: หุ้มทั้งแอปด้วย Listener เพื่อตรวจจับการปัด/แตะ แล้วรี-ซ่อนอัตโนมัติ
      builder:
          (context, child) => Listener(
            behavior: HitTestBehavior.translucent,
            onPointerUp: (_) {
              _rehideTimer?.cancel();
              _rehideTimer = Timer(_rehideDelay, _rehideBottomOnly);
            },
            child: child ?? const SizedBox.shrink(),
          ),
      title: 'G-Cargo',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('th', 'TH'),
      fallbackLocale: const Locale('th', 'TH'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(titleTextStyle: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold), centerTitle: false),
        fontFamily: 'SukhumvitSet',
      ),
      home: const AppLifecycleWrapper(),
    );
  }
}

class AppLifecycleWrapper extends StatefulWidget {
  const AppLifecycleWrapper({super.key});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('🔄 AppLifecycleWrapper: initState - NOT marking as active yet');
    // ไม่เรียก markAppActive() ที่นี่ เพื่อให้ AuthWrapper ตรวจสอบ auth ก่อน
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('🔄 AppLifecycleWrapper: App state changed to $state');

    switch (state) {
      case AppLifecycleState.paused:
        print('🔄 App paused - marking as background');
        AuthService.markAppBackground();
        break;
      case AppLifecycleState.detached:
        print('🔄 App detached - marking as closed');
        AuthService.markAppClosed();
        break;
      case AppLifecycleState.resumed:
        print('🔄 App resumed - marking as active');
        AuthService.markAppActive();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(upgrader: UpgraderService.createUpgrader(), child: const AuthWrapper());
  }
}

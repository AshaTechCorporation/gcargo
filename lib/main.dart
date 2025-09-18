import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/auth/auth_wrapper.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/firebase_options.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/translations/app_translations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'G-Cargo',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('th', 'TH'),
      fallbackLocale: const Locale('th', 'TH'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          centerTitle: false,
        ),
        fontFamily: 'SukhumvitSet',
      ),
      home: const AuthWrapper(),
    );
  }
}

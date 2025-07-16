import 'package:flutter/material.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/login/loginPage.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Register HomeController ใน GetX dependency injection
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          centerTitle: false,
        ),
        fontFamily: 'SukhumvitSet',
      ),
      home: LoginPage(),
    );
  }
}

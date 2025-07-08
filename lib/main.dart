import 'package:flutter/material.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/login/welcomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          centerTitle: false,
        ),
        fontFamily: 'SukhumvitSet',
      ),
      home: FirstPage(),
    );
  }
}

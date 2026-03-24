import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // يعطي شكل حديث للـ Widgets
      ),
      home: PersonProfile(),
    );
  }
}

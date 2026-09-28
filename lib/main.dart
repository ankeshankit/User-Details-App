import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'views/data_entry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Entry App',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      home: DataEntryScreen(),
    );
  }
}
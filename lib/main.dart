// packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// routes
import 'routes/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Find My House',
      home: Home(title: 'my page'),
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}

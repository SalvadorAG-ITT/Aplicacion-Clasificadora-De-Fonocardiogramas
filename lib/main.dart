import 'package:flutter/material.dart';
import 'screens/iphone_screen_page.dart'; // Pantalla IPhoneScreenPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iPhone Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const IPhoneScreenPage(), // Página de inicio
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const PythagoreanAcademiaApp());
}

class PythagoreanAcademiaApp extends StatelessWidget {
  const PythagoreanAcademiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pythagorean Academia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
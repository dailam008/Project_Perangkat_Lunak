import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mustika Energi",
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: const Color(0xFFFFA855),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      routes: {
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignUpPage(),
      },
    );
  }
}

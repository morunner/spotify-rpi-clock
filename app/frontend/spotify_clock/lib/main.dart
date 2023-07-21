import 'package:flutter/material.dart';
import 'login_page/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clock App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'IBM Plex Sans',
            bodyColor: Colors.white,
            displayColor: Colors.white),
      ),
      home: LoginPage(),
    );
  }
}

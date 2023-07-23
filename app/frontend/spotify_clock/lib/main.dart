import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/login/views/login_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
        debugShowCheckedModeBanner: false);
  }
}

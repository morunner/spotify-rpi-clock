import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotify_clock/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vlkxhmrkozzpqwaabnne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsa3hobXJrb3p6cHF3YWFibm5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTE0OTc5OTMsImV4cCI6MjAwNzA3Mzk5M30.xHaEKiOpw_BeVdID6OB0kWPM_Yi0Nv9cTACZzxAJyuE',
  );

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
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false);
  }
}

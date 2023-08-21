import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_clock/src/screens/clock_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotify_clock/src/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
        home: ClockList(),
        routes: Routes.routes,
        debugShowCheckedModeBanner: false);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/backend/authenticator.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/screens/clock_entries_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotify_clock/src/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => ClockEntry(),
    ),
    ChangeNotifierProvider(create: (_) => Authenticator()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Spotify Clock App',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'IBM Plex Sans',
                bodyColor: Colors.white,
              ),
        ),
        home: ClockList(),
        routes: Routes.routes,
        debugShowCheckedModeBanner: false);
  }
}

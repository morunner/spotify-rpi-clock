import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/screens/clock_entries_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotify_clock/src/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  BackendInterface backendInterface = BackendInterface();
  var mostRecentTrackId = await backendInterface.getMostRecentTrackId();

  runApp(ChangeNotifierProvider(
      create: (context) => ClockEntry(
            trackId: mostRecentTrackId,
          ),
      child: const MyApp()));
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

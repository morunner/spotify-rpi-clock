import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'IBM Plex Sans',
              bodyColor: Colors.white,
              displayColor: Colors.white),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0.3 * screenSize.height),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            style: TextButton.styleFrom(
                foregroundColor: Color(0xFF9E2B25),
                backgroundColor: Color(0xFFFFF8F0)),
            child: const Text('Login'),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final toolbarHeight = 0.15 * screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: toolbarHeight,
        title: Padding(
            padding: EdgeInsets.only(
                top: 0.03 * toolbarHeight, bottom: 0.0 * toolbarHeight),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Bearbeiten',
                    style: TextStyle(
                        fontSize: 0.17 * toolbarHeight,
                        fontWeight: FontWeight.w100,
                        color: Color(0xFFE29837))),
                Icon(Icons.add,
                    color: Color(0xFFE29837), size: 0.2 * toolbarHeight),
              ]),
              SizedBox(height: 0.15 * toolbarHeight),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Wecker',
                      style: TextStyle(
                          fontSize: 0.32 * toolbarHeight,
                          fontWeight: FontWeight.bold)))
            ])),
        backgroundColor: Color(0xFF213438),
        foregroundColor: Color(0xFFFFF8F0),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }

  AppBar newMethod() => AppBar();
}

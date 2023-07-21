import 'package:flutter/material.dart';
import '../home_page/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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

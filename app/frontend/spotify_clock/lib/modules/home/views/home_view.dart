import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      appBar: CustomAppBar(),
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
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const toolbarHeight = 1.3 * kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
}

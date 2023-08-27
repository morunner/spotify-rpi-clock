import 'package:flutter/material.dart';
import 'package:spotify_clock/style_scheme.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  MainAppBar({
    required this.title,
    required this.leftNavigationButton,
    required this.rightNavigationButton,
  });

  final String title;
  final Widget leftNavigationButton;
  final Widget rightNavigationButton;
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      title: Padding(
          padding: EdgeInsets.only(
              top: 0.2 * toolbarHeight, bottom: 0.3 * toolbarHeight),
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [leftNavigationButton, rightNavigationButton]),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: TextStyle(
                        fontSize: 0.4 * toolbarHeight,
                        fontWeight: FontWeight.bold)))
          ])),
      backgroundColor: MyColorScheme.darkGreen,
      foregroundColor: MyColorScheme.white,
    );
  }
}

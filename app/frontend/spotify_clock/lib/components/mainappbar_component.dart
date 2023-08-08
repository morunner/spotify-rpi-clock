import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clock/modules/home/controllers/home_controller.dart';

class MainAppBar extends GetWidget<HomeController>
    implements PreferredSizeWidget {
  final String title;
  final List<Widget> navigationChildren;
  final double toolbarHeight;

  MainAppBar({
    required this.title,
    required this.navigationChildren,
    required this.toolbarHeight,
  });

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
                children: navigationChildren),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: TextStyle(
                        fontSize: 0.4 * toolbarHeight,
                        fontWeight: FontWeight.bold)))
          ])),
      backgroundColor: Color(0xFF213438),
      foregroundColor: Color(0xFFFFF8F0),
    );
  }
}

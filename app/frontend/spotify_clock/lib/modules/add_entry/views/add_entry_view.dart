import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:spotify_clock/modules/add_entry/controllers/add_entry_controller.dart';

import 'package:spotify_clock/components/mainappbar_component.dart';
import 'package:spotify_clock/modules/home/views/home_view.dart';

class AddEntryView extends GetView<AddEntryController> {
  AddEntryView({Key? key}) : super(key: key);
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
          title: 'Hinzufügen',
          toolbarHeight: toolbarHeight,
          navigationChildren: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                Get.to(() => HomeView());
              },
              child: const Text('Zurück',
                  style: TextStyle(
                      fontSize: 0.17 * toolbarHeight,
                      fontWeight: FontWeight.w100,
                      color: Color(0xFFE29837))),
            ),
            IconButton(
              icon: Icon(
                Icons.save,
                color: Color(0xFFE29837),
                size: 0.25 * toolbarHeight,
              ),
              onPressed: () {
                Get.to(() => AddEntryView());
              },
            )
          ]),
      body: Column(children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => HomeView());
          },
        )
      ]),
    );
  }
}

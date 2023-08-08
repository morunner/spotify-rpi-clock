import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:spotify_clock/modules/add_entry/controllers/add_entry_controller.dart';

import 'package:spotify_clock/components/mainappbar_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEntryView extends GetView<AddEntryController> {
  AddEntryView({Key? key}) : super(key: key);
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      appBar: MainAppBar(
        title: 'Hinzufügen',
        toolbarHeight: toolbarHeight,
        navigationChildren: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
            },
            child: const Text('Abbrechen',
                style: TextStyle(
                    fontSize: 0.17 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () async {
              await controller.addClockEntry();
              Get.back();
            },
            child: const Text('Fertig',
                style: TextStyle(
                    fontSize: 0.17 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
                width: screenWidth,
                height: 0.2 * MediaQuery.of(context).size.height,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.black),
                  BoxShadow(
                      color: Color(0xFF842B26),
                      spreadRadius: -0.01,
                      blurRadius: 5)
                ]),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime dateTime) {
                    controller.setWakeUpTime(dateTime);
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black),
                  BoxShadow(
                      color: Color(0xFF842B26),
                      spreadRadius: -0.01,
                      blurRadius: 5)
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Auswahl',
                            style: TextStyle(
                              fontSize: 0.3 * toolbarHeight,
                              color: Color(0xFFFFF8F0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFFFF8F0).withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'Ändern',
                                  style: TextStyle(
                                    fontSize: 0.2 * toolbarHeight,
                                    color: Color(0xFFFFF8F0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: Color(0xFFFFF8F0),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

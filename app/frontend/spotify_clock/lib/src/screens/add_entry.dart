import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_clock/src/widgets/add_entry/innershadow_container.dart';
import 'package:spotify_clock/src/widgets/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';

class AddEntryScreen extends StatelessWidget {
  AddEntryScreen({super.key});
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  final clockEntryManager = ClockEntryManager();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      appBar: MainAppBar(
        title: 'Hinzufügen',
        toolbarHeight: toolbarHeight,
        navigationChildren: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Abbrechen',
                style: TextStyle(
                    fontSize: 0.17 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              clockEntryManager.addClockEntry();
              Navigator.pop(context);
            },
            child: const Text('Fertig',
                style: TextStyle(
                    fontSize: 0.17 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InnerShadowContainer(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(fontSize: 15),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime dateTime) {
                    clockEntryManager.setWakeUpTime(dateTime);
                  },
                ),
              ),
            ),
            InnerShadowContainer(
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
                              fontSize: 0.03 * screenHeight,
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
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  'Ändern',
                                  style: TextStyle(
                                    fontSize: 0.025 * screenHeight,
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
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            'assets/images/john_mayer_sobrock.jpeg',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'I guess I just feel like',
                                      style: TextStyle(
                                        fontSize: 0.025 * screenHeight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    'John Mayer',
                                    style: TextStyle(
                                      fontSize: 0.02 * screenHeight,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Sob Rock',
                                    style: TextStyle(
                                      fontSize: 0.02 * screenHeight,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.shuffle, color: Color(0xFFFFF8F0)),
                  Icon(Icons.volume_up, color: Color(0xFFFFF8F0)),
                  Expanded(
                    flex: 5,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          trackShape: RoundedRectSliderTrackShape(),
                          thumbShape: RoundSliderThumbShape(),
                          thumbColor: Color(0xFFFFF8F0),
                          activeTrackColor: Color(0xFF2E2836),
                          inactiveTrackColor: Color(0xFFF4F4F4),
                          trackHeight: 10),
                      child: Slider(
                        value: 40,
                        min: 0,
                        max: 100,
                        onChanged: (double value) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Container(
                  alignment: Alignment.center,
                  color: Color(0xFFFFF8F0).withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                        child: Text(
                          'NixieClock32',
                          style: TextStyle(
                            color: Color(0xFF2E2836),
                            fontSize: 0.025 * screenHeight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.expand_less),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

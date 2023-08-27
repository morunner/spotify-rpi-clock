import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/add_entry/song_select.dart';
import 'package:spotify_clock/src/widgets/add_entry/wakeup_time_picker.dart';
import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';
import 'package:spotify_clock/style_scheme.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _clockEntryManager = ClockEntryManager();

  late double _volumeSliderValue;

  @override
  void initState() {
    super.initState();

    _volumeSliderValue = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var clockEntry = context.watch<ClockEntry>();

    return Scaffold(
      backgroundColor: MyColorScheme.red,
      appBar: MainAppBar(
        title: 'Hinzufügen',
        leftNavigationButton: TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen',
              style: TextStyle(
                  fontSize: MainAppBarStyle.navigationButtonTextSize,
                  color: MyColorScheme.yellow)),
        ),
        rightNavigationButton: TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {
            _clockEntryManager.addClockEntry(clockEntry);
            Navigator.pop(context);
          },
          child: const Text(
            'Fertig',
            style: TextStyle(
                fontSize: MainAppBarStyle.navigationButtonTextSize,
                color: MyColorScheme.yellow),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WakeUpTimePicker(),
            SongSelect(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.shuffle, color: MyColorScheme.white),
                  Icon(Icons.volume_up, color: MyColorScheme.white),
                  Expanded(
                    flex: 5,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          trackShape: RoundedRectSliderTrackShape(),
                          thumbShape: RoundSliderThumbShape(),
                          thumbColor: MyColorScheme.white,
                          activeTrackColor: MyColorScheme.darkGreen,
                          inactiveTrackColor: MyColorScheme.white,
                          trackHeight: 10),
                      child: Slider(
                        value: _volumeSliderValue,
                        min: 0,
                        max: 100,
                        onChanged: (double value) {
                          setState(() => _volumeSliderValue = value);
                        },
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
                  color: MyColorScheme.white.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                        child: Text(
                          'NixieClock32',
                          style: TextStyle(
                            color: MyColorScheme.darkGreen,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.expand_more),
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

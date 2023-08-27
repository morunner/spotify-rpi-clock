import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/add_entry/device_settings.dart';
import 'package:spotify_clock/src/widgets/add_entry/song_select.dart';
import 'package:spotify_clock/src/widgets/add_entry/wakeup_time_picker.dart';
import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';
import 'package:spotify_clock/style_scheme.dart';

class AddEntryScreen extends StatelessWidget {
  final _clockEntryManager = ClockEntryManager();

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
            DeviceSettings(),
          ],
        ),
      ),
    );
  }
}

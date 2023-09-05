import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/add_entry/device_settings.dart';
import 'package:spotify_clock/src/widgets/add_entry/song_select.dart';
import 'package:spotify_clock/src/widgets/add_entry/wakeup_time_picker.dart';
import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/style_scheme.dart';

class AddEntryScreen extends StatelessWidget {
  final backendInterface = BackendInterface();

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
            if (clockEntry.getDeviceId().isNotEmpty) {
              backendInterface.addClockEntry(clockEntry);
              clockEntry.clearDevice();
              Navigator.pop(context);
            } else {
              showDialog<String>(
                  context: context,
                  builder: ((context) => _NoDeviceAlertDialog()));
            }
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 650),
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
        ),
      ),
    );
  }
}

class _NoDeviceAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text(
          'No device set',
          style: TextStyle(color: MyColorScheme.darkGreen),
        ),
        content: const Text(
          'Please select a device in order to save.',
          style: TextStyle(color: MyColorScheme.darkGreen),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('cancel'))
        ]);
  }
}

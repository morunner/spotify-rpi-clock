import 'package:flutter/cupertino.dart';
import 'package:spotify_clock/src/widgets/common/innershadow_container.dart';

class WakeUpTimePicker extends StatelessWidget {
  WakeUpTimePicker({required this.onDateTimeChanged});

  final Function(DateTime time) onDateTimeChanged;

  @override
  Widget build(BuildContext context) {
    return InnerShadowContainer(
      child: SizedBox(
        height: 150,
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
              onDateTimeChanged(dateTime);
            },
          ),
        ),
      ),
    );
  }
}

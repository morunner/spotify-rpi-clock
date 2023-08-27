import 'package:flutter/material.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';

class ClockEntriesList extends StatelessWidget {
  ClockEntriesList(
      {super.key, required this.stream, required this.onListItemDelete});

  final Stream<List<ClockEntry>> stream;
  final Future Function(String title) onListItemDelete;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClockEntry>>(
      stream: stream,
      builder: (context, snapshot) => _listBuilder(context, snapshot),
    );
  }

  _listBuilder(context, snapshot) {
    Color textColor = Color(0xFF213438);
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final clockEntries = snapshot.data!;

    return ListView.builder(
      itemCount: clockEntries.length,
      itemBuilder: ((context, index) {
        return ListTile(
          title: Text(clockEntries[index].getWakeUpTime(),
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              )),
          subtitle: Text(
              ' ${clockEntries[index].getTitle()} (${clockEntries[index].getArtist()})',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              )),
          trailing: IconButton(
              icon:
                  Icon(Icons.delete_outline_outlined, color: Color(0xFF9E2B25)),
              onPressed: () async {
                String title = clockEntries[index].getTitle();
                await onListItemDelete(title);
              }),
          tileColor: Color(0xFFD5D5D5),
        );
      }),
    );
  }
}

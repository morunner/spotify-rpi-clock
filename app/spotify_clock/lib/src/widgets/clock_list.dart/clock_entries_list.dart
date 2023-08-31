import 'package:flutter/material.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:spotify_clock/style_scheme.dart';

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
    Color textColor = MyColorScheme.darkGreen;
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final clockEntries = snapshot.data!;

    return ListView.builder(
      itemCount: clockEntries.length,
      itemBuilder: ((context, index) {
        return FutureBuilder<Track>(
          future: clockEntries[index].getTrack(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            Track track = snapshot.data ?? Track();

            return ListTile(
              title: Text(clockEntries[index].getWakeUpTime(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                  )),
              subtitle: Text(' ${track.getTitle()} (${track.getArtist()})',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  )),
              trailing: IconButton(
                  icon: Icon(Icons.delete_outline_outlined,
                      color: MyColorScheme.red),
                  onPressed: () async {
                    await onListItemDelete(track.getSpotifyId());
                  }),
              tileColor: Color(0xFFD5D5D5),
            );
          },
        );
      }),
    );
  }
}

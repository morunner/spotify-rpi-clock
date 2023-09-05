import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/data/device.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:spotify_clock/style_scheme.dart';

class ClockEntriesList extends StatelessWidget {
  ClockEntriesList(
      {super.key, required this.stream, required this.onListItemDelete});

  final Stream<List<ClockEntry>> stream;
  final Future Function(String title) onListItemDelete;
  final backendInterface = BackendInterface();

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
        return FutureBuilder<Map<String, dynamic>>(
          future: clockEntries[index].getPlaybackInfo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            Map<String, dynamic> data = snapshot.data ?? {};
            Track track = data['track'];
            Device device =
                data['device'] ?? Device(name: 'currently unavailable');

            return ListTile(
              title: Text(clockEntries[index].getWakeUpTime(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                  )),
              subtitle: Text(
                  ' ${track.getTitle()} (${track.getArtist()}) on: ${device.getName()}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  )),
              trailing: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          activeColor: MyColorScheme.darkGreen,
                          value: clockEntries[index].isEnabled(),
                          onChanged: (state) {
                            backendInterface.updateClockEntry(
                                clockEntries[index].getId(),
                                {'enabled': !clockEntries[index].isEnabled()});
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.remove, color: MyColorScheme.red),
                        onPressed: () async {
                          await onListItemDelete(track.getSpotifyId());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              tileColor: Color(0xFFD5D5D5),
            );
          },
        );
      }),
    );
  }
}

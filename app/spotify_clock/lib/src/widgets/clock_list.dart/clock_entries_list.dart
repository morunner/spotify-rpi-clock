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
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final clockEntries = snapshot.data!;

    return _ListViewBuilder(
      clockEntries: clockEntries,
      onListItemDelete: onListItemDelete,
    );
  }
}

class _ListViewBuilder extends StatelessWidget {
  _ListViewBuilder({
    required this.clockEntries,
    required this.onListItemDelete,
  });

  final List<ClockEntry> clockEntries;
  final Future Function(String title) onListItemDelete;

  @override
  Widget build(BuildContext context) {
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

            return _ListTile(
              clockEntry: clockEntries[index],
              track: track,
              device: device,
              onListItemDelete: onListItemDelete,
            );
          },
        );
      }),
    );
  }
}

class _ListTile extends StatelessWidget {
  _ListTile(
      {required this.clockEntry,
      required this.track,
      required this.device,
      required this.onListItemDelete});

  final ClockEntry clockEntry;
  final Track track;
  final Device device;
  final Future Function(String title) onListItemDelete;

  final Color textColor = MyColorScheme.darkGreen;
  final backendInterface = BackendInterface();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(clockEntry.getWakeUpTime(),
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
                  value: clockEntry.isEnabled(),
                  onChanged: (state) {
                    backendInterface.updateClockEntry(clockEntry.getId(),
                        {'enabled': !clockEntry.isEnabled()});
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
  }
}

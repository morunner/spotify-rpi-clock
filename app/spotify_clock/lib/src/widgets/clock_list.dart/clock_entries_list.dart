import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/data/device.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:spotify_clock/style_scheme.dart';

class ClockEntriesList extends StatelessWidget {
  ClockEntriesList({super.key, required this.stream});

  final Stream<List<ClockEntry>> stream;
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
    );
  }
}

class _ListViewBuilder extends StatelessWidget {
  _ListViewBuilder({
    required this.clockEntries,
  });

  final List<ClockEntry> clockEntries;

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
            );
          },
        );
      }),
    );
  }
}

class _ListTile extends StatelessWidget {
  _ListTile({
    required this.clockEntry,
    required this.track,
    required this.device,
  });

  final ClockEntry clockEntry;
  final Track track;
  final Device device;

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
                  await _onListItemDelete(clockEntry.getId());
                },
              ),
            ),
          ],
        ),
      ),
      tileColor: Color(0xFFD5D5D5),
    );
  }

  Future _onListItemDelete(int id) async {
    final backendInterface = BackendInterface();
    await backendInterface.removeClockEntry(id);
  }
}

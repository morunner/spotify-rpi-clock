import 'package:flutter/material.dart';

import 'package:spotify_clock/src/widgets/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';
import 'package:spotify_clock/src/routing/routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ClockList extends StatelessWidget {
  ClockList({super.key});

  final clockEntryManager = ClockEntryManager();
  static const double toolbarHeight = 1.4 * kToolbarHeight;
  final _clockEntriesStream =
      Supabase.instance.client.from('clock_entries').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF9E2B25),
        appBar: MainAppBar(
            title: 'Wecker',
            toolbarHeight: toolbarHeight,
            navigationChildren: [
              Text('Bearbeiten',
                  style: TextStyle(
                      fontSize: 0.17 * toolbarHeight,
                      fontWeight: FontWeight.w100,
                      color: Color(0xFFE29837))),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Color(0xFFE29837),
                  size: 0.25 * toolbarHeight,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.ADD_ENTRY);
                },
              )
            ]),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _clockEntriesStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final clockEntries = snapshot.data!;

            return ListView.builder(
              itemCount: clockEntries.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(
                      '${clockEntries[index]['wakeup_time'].split(':')[0]}:${clockEntries[index]['wakeup_time'].split(':')[1]}',
                      style: TextStyle(
                        color: Color(0xFF213438),
                        fontSize: 0.3 * toolbarHeight,
                      )),
                  subtitle: Text(
                      ' ${clockEntries[index]['title']} (${clockEntries[index]['artist']})',
                      style: TextStyle(
                        color: Color(0xFF213438),
                        fontSize: 0.15 * toolbarHeight,
                      )),
                  trailing: IconButton(
                      icon: Icon(Icons.delete_outline_outlined,
                          color: Color(0xFF9E2B25)),
                      onPressed: () async {
                        await clockEntryManager
                            .removeClockEntry(clockEntries[index]['id']);
                      }),
                  tileColor: Color(0xFFD5D5D5),
                );
              }),
            );
          },
        ));
  }
}
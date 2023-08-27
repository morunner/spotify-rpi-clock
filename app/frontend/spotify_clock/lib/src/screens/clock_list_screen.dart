import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/clock_list.dart/clock_entries_list.dart';

import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';
import 'package:spotify_clock/src/routing/routes.dart';

class ClockList extends StatelessWidget {
  ClockList({super.key});

  final clockEntryManager = ClockEntryManager();
  final spotifyClient = SpotifyClient();
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF9E2B25),
        appBar: MainAppBar(
            title: 'Wecker',
            toolbarHeight: toolbarHeight,
            navigationChildren: [
              TextButton(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 0.2 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837),
                  ),
                ),
                onPressed: () async {
                  spotifyClient.login();
                },
              ),
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
        body: StreamBuilder<List<ClockEntry>>(
          stream: clockEntryManager.stream,
          builder: (context, snapshot) {
            return ClockEntriesList(
                stream: clockEntryManager.stream,
                onListItemDelete: _onListItemDelete);
          },
        ));
  }

  Future _onListItemDelete(String title) async {
    await clockEntryManager.removeClockEntry(title);
  }
}

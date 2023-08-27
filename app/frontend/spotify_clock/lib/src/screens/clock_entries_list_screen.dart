import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/clock_list.dart/clock_entries_list.dart';

import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';
import 'package:spotify_clock/src/routing/routes.dart';
import 'package:spotify_clock/style_scheme.dart';

class ClockList extends StatelessWidget {
  ClockList({super.key});

  final clockEntryManager = ClockEntryManager();
  final spotifyClient = SpotifyClient();
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColorScheme.red,
        appBar: MainAppBar(
            title: 'Wecker',
            leftNavigationButton: TextButton(
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: MainAppBarStyle.navigationButtonTextSize,
                  color: MyColorScheme.yellow,
                ),
              ),
              onPressed: () async {
                spotifyClient.login();
              },
            ),
            rightNavigationButton: IconButton(
              icon: Icon(
                Icons.add,
                color: MyColorScheme.yellow,
                size: MainAppBarStyle.navigationButtonIconSize,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.ADD_ENTRY);
              },
            )),
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

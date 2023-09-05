import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/widgets/clock_list.dart/clock_entries_list.dart';

import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/routing/routes.dart';
import 'package:spotify_clock/style_scheme.dart';

class ClockList extends StatelessWidget {
  ClockList({super.key});

  final backendInterface = BackendInterface();
  final spotifyClient = SpotifyClient();

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
          stream: backendInterface.stream,
          builder: (context, snapshot) {
            return ClockEntriesList(
                stream: backendInterface.stream,
                onListItemDelete: _onListItemDelete);
          },
        ));
  }

  Future _onListItemDelete(String trackId) async {
    await backendInterface.removeClockEntry(trackId);
  }
}

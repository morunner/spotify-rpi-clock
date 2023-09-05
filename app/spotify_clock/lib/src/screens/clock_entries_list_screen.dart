import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/backend/authenticator.dart';
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
    final auth = context.watch<Authenticator>();

    return Scaffold(
        backgroundColor: MyColorScheme.red,
        appBar: auth.isSignedIn()
            ? MainAppBar(
                title: 'Wecker',
                leftNavigationButton: _LogoutButton(),
                rightNavigationButton: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: MyColorScheme.yellow,
                    size: MainAppBarStyle.navigationButtonIconSize,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.ADD_ENTRY);
                  },
                ),
              )
            : null,
        body: StreamBuilder<List<ClockEntry>>(
          stream: backendInterface.stream,
          builder: (context, snapshot) {
            if (auth.isSignedIn()) {
              return ClockEntriesList(
                  stream: backendInterface.stream,
                  onListItemDelete: _onListItemDelete);
            } else {
              return Center(
                child: _LoginButton(),
              );
            }
          },
        ));
  }

  Future _onListItemDelete(String trackId) async {
    await backendInterface.removeClockEntry(trackId);
  }
}

class _LoginButton extends StatelessWidget {
  final spotifyClient = SpotifyClient();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        spotifyClient.login();
      },
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Text('Login',
            style: TextStyle(color: MyColorScheme.darkGreen, fontSize: 15)),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  _LogoutButton();

  final spotifyClient = SpotifyClient();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        'Logout',
        style: TextStyle(
          fontSize: MainAppBarStyle.navigationButtonTextSize,
          color: MyColorScheme.yellow,
        ),
      ),
      onPressed: () async {
        await spotifyClient.logout();
      },
    );
  }
}

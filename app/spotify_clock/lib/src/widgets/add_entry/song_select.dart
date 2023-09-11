import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:spotify_clock/src/data/track.dart';
import 'package:spotify_clock/src/widgets/common/innershadow_container.dart';
import 'package:spotify_clock/style_scheme.dart';

class SongSelect extends StatefulWidget {
  const SongSelect({super.key});

  @override
  State<SongSelect> createState() => _SongSelectState();
}

class _SongSelectState extends State<SongSelect> {
  BackendInterface backendInterface = BackendInterface();

  @override
  Widget build(BuildContext context) {
    return InnerShadowContainer(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            _SongSelectionHeader(),
            Divider(
              color: MyColorScheme.white,
            ),
            _SongSelection(),
          ],
        ),
      ),
    );
  }
}

class _SongSelectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Auswahl',
          style: TextStyle(
            fontSize: 25,
            color: MyColorScheme.white,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: MyColorScheme.white.withOpacity(0.15),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: TextButton(
            child: Text(
              'Ändern',
              style: TextStyle(
                fontSize: 20,
                color: MyColorScheme.white,
              ),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: ((context) => _SongSelectionDialog()),
            ),
          ),
        ),
      ],
    );
  }
}

class _SongSelectionDialog extends StatelessWidget {
  final _spotifyClient = SpotifyClient();
  final textStyle = TextStyle(color: MyColorScheme.darkGreen);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select your song',
        style: textStyle,
      ),
      content: Consumer<ClockEntry>(
        builder: (context, clockEntry, child) => TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            style: textStyle,
            decoration: InputDecoration(
                labelStyle: textStyle, hintText: 'Search track'),
          ),
          debounceDuration: Duration(milliseconds: 50),
          suggestionsCallback: (pattern) async =>
              _onSuggestionsCallback(pattern),
          itemBuilder: (BuildContext context, track) {
            return ListTile(
              title: Text(track.getTitle()),
              subtitle: Text(track.getArtist()),
              textColor: MyColorScheme.darkGreen,
            );
          },
          onSuggestionSelected: (track) {
            _onSuggestionSelected(context, track);
            Navigator.of(context).pop();
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<List<Track>> _onSuggestionsCallback(String pattern) async {
    List<Track> tracks = [];
    if (pattern.isNotEmpty) {
      tracks = await _spotifyClient.getTracksList(pattern, 5);
    }
    return tracks;
  }

  void _onSuggestionSelected(BuildContext context, Track track) {
    var clockEntryProvider = Provider.of<ClockEntry>(context, listen: false);
    clockEntryProvider.setTrackId(track.getSpotifyId());
  }
}

class _SongSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var clockEntry = context.watch<ClockEntry>();
    return FutureBuilder<Track>(
        future: clockEntry.getTrack(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Track track = snapshot.data ?? Track();
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: track.getImage(),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Text(
                            track.getTitle(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          track.getArtist(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          track.getAlbum(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                            color: MyColorScheme.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

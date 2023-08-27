import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/widgets/common/innershadow_container.dart';
import 'package:spotify_clock/src/widgets/common/mainappbar.dart';
import 'package:spotify_clock/src/backend/clock_entry_manager.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  final _clockEntryManager = ClockEntryManager();
  final _spotifyClient = SpotifyClient();

  late double _volumeSliderValue;
  late bool _recentSelUpdated;

  @override
  void initState() {
    super.initState();

    _volumeSliderValue = 0;
    _recentSelUpdated = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9E2B25),
      appBar: MainAppBar(
        title: 'Hinzufügen',
        toolbarHeight: toolbarHeight,
        navigationChildren: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen',
                style: TextStyle(
                    fontSize: 0.2 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              _clockEntryManager.addClockEntry();
              Navigator.pop(context);
            },
            child: const Text('Fertig',
                style: TextStyle(
                    fontSize: 0.2 * toolbarHeight,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFFE29837))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InnerShadowContainer(
              child: SizedBox(
                height: 150,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(fontSize: 15),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime dateTime) {
                      setState(() => _clockEntryManager.clockEntry
                          .setWakeUpTime(dateTime));
                    },
                  ),
                ),
              ),
            ),
            InnerShadowContainer(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Auswahl',
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFFFFF8F0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFFFF8F0).withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: TextButton(
                                    child: Text(
                                      'Ändern',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFFFFF8F0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final name = await openDialog();
                                      if (name == null || name.isEmpty) return;
                                      setState(() => _clockEntryManager
                                          .clockEntry
                                          .setTitle(name));
                                    }),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                      color: Color(0xFFFFF8F0),
                    ),
                    FutureBuilder(
                        future: _clockEntryManager.getMostRecentSelection(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if (_recentSelUpdated == false) {
                              final mostRecentSelection = snapshot.data[0];
                              _clockEntryManager.clockEntry
                                  .setTitle(mostRecentSelection['title']);
                              _clockEntryManager.clockEntry
                                  .setArtist(mostRecentSelection['artist']);
                              _clockEntryManager.clockEntry.setAlbum(
                                  mostRecentSelection['album'],
                                  mostRecentSelection['cover_url']);
                              _recentSelUpdated = true;
                            }
                            return Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child:
                                      _clockEntryManager.clockEntry.getImage(),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Text(
                                              _clockEntryManager.clockEntry
                                                  .getTitle(),
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Text(
                                            _clockEntryManager.clockEntry
                                                .getArtist(),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            _clockEntryManager.clockEntry
                                                .getAlbum(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFFFFF8F0)
                                                  .withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.shuffle, color: Color(0xFFFFF8F0)),
                  Icon(Icons.volume_up, color: Color(0xFFFFF8F0)),
                  Expanded(
                    flex: 5,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          trackShape: RoundedRectSliderTrackShape(),
                          thumbShape: RoundSliderThumbShape(),
                          thumbColor: Color(0xFFFFF8F0),
                          activeTrackColor: Color(0xFF2E2836),
                          inactiveTrackColor: Color(0xFFF4F4F4),
                          trackHeight: 10),
                      child: Slider(
                        value: _volumeSliderValue,
                        min: 0,
                        max: 100,
                        onChanged: (double value) {
                          setState(() => _volumeSliderValue = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Container(
                  alignment: Alignment.center,
                  color: Color(0xFFFFF8F0).withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 2, 0, 2),
                        child: Text(
                          'NixieClock32',
                          style: TextStyle(
                            color: Color(0xFF2E2836),
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.expand_more),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select your song',
            style: TextStyle(
              color: Color(0xFF213438),
            ),
          ),
          content: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              style: TextStyle(
                color: Color(0xFF213438),
              ),
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: Color(0xFF213438)),
                  hintText: 'Search track'),
            ),
            debounceDuration: Duration(milliseconds: 50),
            suggestionsCallback: (pattern) async {
              List<dynamic> tracks = [];

              if (pattern.isNotEmpty) {
                tracks = await _spotifyClient.getTracksList(pattern, 5);
              }
              return tracks;
            },
            itemBuilder: (BuildContext context, track) {
              return ListTile(
                title: Text(track.name),
                subtitle: Text(track.artist),
                textColor: Color(0xFF213438),
              );
            },
            onSuggestionSelected: (track) {
              if (track != null) {
                setState(() {
                  _clockEntryManager.clockEntry.setArtist(track.artist);
                  _clockEntryManager.clockEntry.setTitle(track.name);
                  _clockEntryManager.clockEntry
                      .setAlbum(track.album, track.coverUrl);
                });
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
}

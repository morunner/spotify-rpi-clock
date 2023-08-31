import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/track.dart';

class ClockEntry extends ChangeNotifier {
  ClockEntry({
    this.wakeUpTime = '',
    this.enabled = false,
    this.trackId = '',
    this.deviceId = '',
  });

  String wakeUpTime;
  bool enabled;
  String trackId;
  String deviceId;

  SpotifyClient spotifyClient = SpotifyClient();

  get() {
    return {
      'wakeup_time': wakeUpTime,
      'enabled': enabled,
      'track_id': trackId,
      'device_id': deviceId,
    };
  }

  Future<Track> getTrack() async {
    return await spotifyClient.getTrack(trackId);
  }

  setWakeUpTime(DateTime time) {
    wakeUpTime = DateFormat('HH:mm').format(time).toString();
    notifyListeners();
  }

  setEnabled(bool enabled) {
    this.enabled = enabled;
    notifyListeners();
  }

  setTrackId(String trackId) {
    this.trackId = trackId;
    notifyListeners();
  }

  getWakeUpTime() {
    return wakeUpTime;
  }

  isEnabled() {
    return enabled;
  }

  getTrackId() {
    return trackId;
  }

  getMostRecentSelection() {
    BackendInterface backendInterface = BackendInterface();
    SpotifyClient spotifyClient = SpotifyClient();
    var mostRecentSelection = backendInterface.getMostRecentTrackId();
    Track track = spotifyClient.getTrack(mostRecentSelection['track_id']);
    return track;
  }
}

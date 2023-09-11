import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotify_clock/src/backend/backend_interface.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/device.dart';
import 'package:spotify_clock/src/data/track.dart';

class ClockEntry extends ChangeNotifier {
  ClockEntry({
    this.id = 0,
    this.wakeUpTime = '',
    this.enabled = true,
    this.trackId = '',
    this.deviceId = '',
  });

  int id;
  String wakeUpTime;
  bool enabled;
  String trackId;
  String deviceId;

  SpotifyClient spotifyClient = SpotifyClient();

  clearDevice() {
    deviceId = '';
  }

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

  getDevice() async {
    List<Device> devices = await spotifyClient.getAvailableDevices();
    for (var device in devices) {
      if (device.getSpotifyId() == deviceId) {
        return device;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getPlaybackInfo() async {
    return {
      'track': await getTrack(),
      'device': await getDevice(),
    };
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

  setDeviceId(String deviceId) {
    this.deviceId = deviceId;
    notifyListeners();
  }

  getId() {
    return id;
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

  getDeviceId() {
    return deviceId;
  }

  getMostRecentSelection() {
    BackendInterface backendInterface = BackendInterface();
    SpotifyClient spotifyClient = SpotifyClient();
    var mostRecentSelection = backendInterface.getMostRecentTrackId();
    Track track = spotifyClient.getTrack(mostRecentSelection['track_id']);
    return track;
  }
}

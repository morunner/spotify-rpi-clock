import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockEntry {
  ClockEntry(
      {String wakeUpTime = '',
      String title = '',
      String artist = '',
      String album = '',
      bool enabled = false,
      String coverUrl = ''})
      : _enabled = enabled,
        _coverUrl = coverUrl,
        _artist = artist,
        _album = album,
        _title = title,
        _wakeUpTime = wakeUpTime;

  String _wakeUpTime;
  String _title;
  String _artist;
  String _album;
  String _coverUrl;
  bool _enabled;

  Image _image = Image.asset(
    'assets/images/john_mayer_sobrock.jpeg',
    fit: BoxFit.fitWidth,
  );

  get() {
    Map<String, dynamic> clockEntry = {
      'wakeup_time': _wakeUpTime,
      'title': _title,
      'artist': _artist,
      'cover_url': _coverUrl,
      'enabled': _enabled,
    };
    return clockEntry;
  }

  setWakeUpTime(DateTime time) {
    _wakeUpTime = DateFormat('HH:mm').format(time).toString();
  }

  setTitle(String title) {
    _title = title;
  }

  setArtist(String artist) {
    _artist = artist;
  }

  setAlbum(String album, String coverUrl) {
    _album = album;
    _coverUrl = coverUrl;

    if (_coverUrl.isNotEmpty) {
      _image = Image.network(
        _coverUrl,
        fit: BoxFit.fitWidth,
      );
    } else {
      _image = Image.asset(
        'assets/images/john_mayer_sobrock.jpeg',
      );
    }
  }

  setEnabled(bool enabled) {
    _enabled = enabled;
  }

  getWakeUpTime() {
    return _wakeUpTime;
  }

  getTitle() {
    return _title;
  }

  getArtist() {
    return _artist;
  }

  getAlbum() {
    return _album;
  }

  isEnabled() {
    return _enabled;
  }

  getCoverUrl() {
    return _coverUrl;
  }

  getImage() {
    return _image;
  }
}

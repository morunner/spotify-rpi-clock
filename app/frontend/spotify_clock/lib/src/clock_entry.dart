import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockEntry {
  ClockEntry(
      {String wakeup_time = '00:00:00',
      String title = 'title',
      String artist = 'artist',
      bool enabled = false,
      String cover_url = ''})
      : _enabled = enabled,
        _cover_url = cover_url,
        _artist = artist,
        _title = title,
        _wakeup_time = wakeup_time;

  String _wakeup_time;
  String _title;
  String _artist;
  String _cover_url;
  bool _enabled;

  Image _image = Image.asset(
    'assets/images/john_mayer_sobrock.jpeg',
    fit: BoxFit.fitWidth,
  );

  get() {
    Map<String, dynamic> clockEntry = {
      'wakeup_time': _wakeup_time,
      'title': _title,
      'artist': _artist,
      'cover_url': _cover_url,
      'enabled': _enabled,
    };
    return clockEntry;
  }

  setWakeUpTime(DateTime time) {
    _wakeup_time = DateFormat('HH:mm').format(time).toString();
  }

  setTitle(String title) {
    _title = title;
  }

  setArtist(String artist) {
    _artist = artist;
  }

  setEnabled(bool enabled) {
    _enabled = enabled;
  }

  setCover(String url) {
    _cover_url = url;

    if (_cover_url.isNotEmpty) {
      _image = Image.network(
        _cover_url,
        fit: BoxFit.fitWidth,
      );
    } else {
      _image = Image.asset(
        'assets/images/john_mayer_sobrock.jpeg',
        fit: BoxFit.fitWidth,
      );
    }
  }

  getWakeUpTime() {
    return _wakeup_time;
  }

  getTitle() {
    return _title;
  }

  getArtist() {
    return _artist;
  }

  isEnabled() {
    return _enabled;
  }

  getCoverUrl() {
    return _cover_url;
  }

  getImage() {
    return _image;
  }
}

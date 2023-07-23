import 'package:flutter/material.dart';

class ClockEntryModel {
  final TimeOfDay? time;
  final String? songTitle;
  final String? artist;
  final bool? enabled;

  ClockEntryModel({
    @required this.time,
    @required this.songTitle,
    @required this.artist,
    @required this.enabled,
  });
}

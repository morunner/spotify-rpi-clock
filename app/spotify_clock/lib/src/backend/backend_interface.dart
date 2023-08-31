import 'dart:async';

import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendInterface {
  BackendInterface() {
    _transformer = StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(_parseClockEntries(data));
    });
    stream = _supabase
        .from('clock_entries')
        .stream(primaryKey: ['id']).transform(_transformer);
  }

  final _supabase = Supabase.instance.client;

  late StreamTransformer<List<Map<String, dynamic>>, List<ClockEntry>>
      _transformer;
  late Stream<List<ClockEntry>> stream;

  addClockEntry(ClockEntry clockEntry) async {
    if (clockEntry.getWakeUpTime().isEmpty) {
      clockEntry.setWakeUpTime(DateTime.now());
    }
    await _supabase.from('clock_entries').insert(clockEntry.get());
    await updateMostRecentSelection(clockEntry);
  }

  removeClockEntry(String trackId) async {
    await Supabase.instance.client
        .from('clock_entries')
        .delete()
        .match({'track_id': trackId});
  }

  updateMostRecentSelection(clockEntry) async {
    var mostRecentSelection = {
      'track_id': clockEntry.getTrackId(),
    };

    List<dynamic> data = await _supabase.from('most_recent_selection').select();
    if (data.isEmpty) {
      await _supabase.from('most_recent_selection').insert(mostRecentSelection);
    } else {
      await _supabase
          .from('most_recent_selection')
          .update(mostRecentSelection)
          .eq('id', 1);
    }
  }

  getMostRecentTrackId() async {
    final data =
        await _supabase.from('most_recent_selection').select().eq('id', 1);
    return data[0]['track_id'];
  }

  _parseClockEntries(data) {
    List<ClockEntry> clockEntries = [];
    for (final entry in data) {
      String wakeUpTime =
          '${entry['wakeup_time'].split(':')[0]}:${entry['wakeup_time'].split(':')[1]}';
      bool enabled = entry['enabled'];
      String trackId = entry['track_id'];
      String deviceId = entry['device_id'];
      clockEntries.add(
        ClockEntry(
          wakeUpTime: wakeUpTime,
          enabled: enabled,
          trackId: trackId,
          deviceId: deviceId,
        ),
      );
    }
    return clockEntries;
  }
}

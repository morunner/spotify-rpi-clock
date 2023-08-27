import 'package:spotify_clock/src/data/clock_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClockEntryManager {
  ClockEntryManager();

  ClockEntry clockEntry = ClockEntry();
  ClockEntry mostRecentSelection = ClockEntry();

  final _supabase = Supabase.instance.client;

  final stream =
      Supabase.instance.client.from('clock_entries').stream(primaryKey: ['id']);

  addClockEntry() async {
    if (clockEntry.getWakeUpTime().isEmpty) {
      clockEntry.setWakeUpTime(DateTime.now());
    }
    await _supabase.from('clock_entries').insert(clockEntry.get());
    await updateMostRecentSelection();
  }

  removeClockEntry(int id) async {
    await Supabase.instance.client
        .from('clock_entries')
        .delete()
        .match({'id': id});
  }

  updateMostRecentSelection() async {
    var mostRecentSelection = {
      'title': clockEntry.getTitle(),
      'artist': clockEntry.getArtist(),
      'cover_url': clockEntry.getCoverUrl(),
      'album': clockEntry.getAlbum()
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

  getMostRecentSelection() async {
    final data =
        await _supabase.from('most_recent_selection').select().eq('id', 1);
    return data;
  }
}

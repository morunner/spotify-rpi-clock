import 'package:spotify_clock/src/clock_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClockEntryManager {
  ClockEntryManager();

  ClockEntry clockEntry = ClockEntry();

  final stream =
      Supabase.instance.client.from('clock_entries').stream(primaryKey: ['id']);

  addClockEntry() async {
    if (clockEntry.getWakeUpTime().isEmpty) {
      clockEntry.setWakeUpTime(DateTime.now());
    }
    await Supabase.instance.client
        .from('clock_entries')
        .insert(clockEntry.get());
  }

  removeClockEntry(int id) async {
    await Supabase.instance.client
        .from('clock_entries')
        .delete()
        .match({'id': id});
  }
}

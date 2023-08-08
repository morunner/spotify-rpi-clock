import 'package:get/get.dart';
import 'package:spotify_clock/data/model/clock_entry_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  Rx<List<ClockEntryModel>> clockEntries = Rx<List<ClockEntryModel>>([]);
  late ClockEntryModel clockEntryModel;
  var itemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  addClockEntry(
      DateTime time, String songTitle, String artist, bool enabled) async {
    final dateTime = DateFormat('HH:mm').format(time).toString();

    await Supabase.instance.client.from('clock_entries').insert({
      'wakeup_time': dateTime,
      'title': songTitle,
      'artist': artist,
      'enabled': enabled
    });
  }

  removeCLockEntry(int id) async {
    await Supabase.instance.client
        .from('clock_entries')
        .delete()
        .match({'id': id});
  }
}

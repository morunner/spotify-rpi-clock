import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEntryController extends GetxController {
  Map<String, dynamic> clockEntry = {
    'wakeup_time': '00:00:00',
    'title': 'title',
    'artist': 'artist',
    'enabled': false,
  };

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

  setWakeUpTime(DateTime time) {
    clockEntry['wakeup_time'] = DateFormat('HH:mm').format(time).toString();
  }

  setTitle(String title) {
    clockEntry['title'] = title;
  }

  setArtist(String artist) {
    clockEntry['artist'] = artist;
  }

  setEnabled(bool enabled) {
    clockEntry['enabled'] = enabled;
  }

  addClockEntry() async {
    await Supabase.instance.client.from('clock_entries').insert(clockEntry);
  }
}

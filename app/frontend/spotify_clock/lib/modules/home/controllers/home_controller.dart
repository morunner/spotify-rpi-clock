import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clock/data/model/clock_entry_model.dart';

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

  addClockEntry(TimeOfDay time, String songTitle, String artist, bool enabled) {
    clockEntryModel = ClockEntryModel(
        time: time, songTitle: songTitle, artist: artist, enabled: enabled);
    clockEntries.value.add(clockEntryModel);
    itemCount.value = clockEntries.value.length;
  }

  removeCLockEntry(int index) {
    clockEntries.value.removeAt(index);
    itemCount.value = clockEntries.value.length;
  }
}

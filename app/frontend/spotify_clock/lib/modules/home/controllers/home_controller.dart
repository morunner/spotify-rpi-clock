import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:spotify_clock/data/model/clock_entry_model.dart';

class HomeController extends GetxController {
  Rx<List<ClockEntryModel>> clockEntries = Rx<List<ClockEntryModel>>([]);
  late ClockEntryModel clockEntryModel;
  var itemCount = 0.obs;
  RxBool isPanelOpen = false.obs;

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

  setPanelState(bool isOpen) {
    isPanelOpen.value = isOpen;
  }
}

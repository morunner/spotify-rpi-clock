import 'package:get/get.dart';

import 'package:spotify_clock/modules/add_entry/controllers/add_entry_controller.dart';

class AddEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEntryController>(
      () => AddEntryController(),
    );
  }
}

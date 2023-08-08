import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
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

  removeClockEntry(int id) async {
    await Supabase.instance.client
        .from('clock_entries')
        .delete()
        .match({'id': id});
  }
}

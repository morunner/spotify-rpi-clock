import 'package:get/get.dart';
import 'package:spotify_clock/modules/add_entry/bindings/add_entry_binding.dart';

import 'package:spotify_clock/modules/home/views/home_view.dart';
import 'package:spotify_clock/modules/add_entry/views/add_entry_view.dart';
import 'package:spotify_clock/modules/home/bindings/home_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ADD_ENTRY,
      page: () => AddEntryView(),
      binding: AddEntryBinding(),
    )
  ];
}

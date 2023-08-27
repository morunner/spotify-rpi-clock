import 'package:spotify_clock/src/screens/add_entry_screen.dart';
import 'package:spotify_clock/src/screens/clock_list_screen.dart';

abstract class Routes {
  Routes._();
  static const INITIAL = HOME;

  static const HOME = _Paths.HOME;
  static const ADD_ENTRY = _Paths.ADD_ENTRY;

  static final routes = {
    _Paths.HOME: (context) => ClockList(),
    _Paths.ADD_ENTRY: (context) => AddEntryScreen(),
  };
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const ADD_ENTRY = '/add-entry';
}

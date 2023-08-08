part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const ADD_ENTRY = _Paths.ADD_ENTRY;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const ADD_ENTRY = '/add-entry';
}
